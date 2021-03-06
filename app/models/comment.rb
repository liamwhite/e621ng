class Comment < ApplicationRecord
  include Mentionable

  validate :validate_post_exists, :on => :create
  validate :validate_creator_is_not_limited, :on => :create
  validates_presence_of :body, :message => "has no content"
  belongs_to :post
  belongs_to_creator
  belongs_to_updater
  has_many :votes, :class_name => "CommentVote", :dependent => :destroy
  after_create :update_last_commented_at_on_create
  after_update(:if => ->(rec) {(!rec.is_deleted? || !rec.saved_change_to_is_deleted?) && CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log("comment ##{rec.id} updated by #{CurrentUser.name}",:comment_update)
  end
  after_save :update_last_commented_at_on_destroy, :if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted?}
  after_save(:if => ->(rec) {rec.is_deleted? && rec.saved_change_to_is_deleted? && CurrentUser.id != rec.creator_id}) do |rec|
    ModAction.log("comment ##{rec.id} deleted by #{CurrentUser.name}",:comment_delete)
  end
  mentionable(
    :message_field => :body, 
    :title => ->(user_name) {"#{creator_name} mentioned you in a comment on post ##{post_id}"},
    :body => ->(user_name) {"@#{creator_name} mentioned you in a \"comment\":/posts/#{post_id}#comment-#{id} on post ##{post_id}:\n\n[quote]\n#{DText.excerpt(body, "@"+user_name)}\n[/quote]\n"},
  )

  module SearchMethods
    def recent
      reorder("comments.id desc").limit(6)
    end

    def hidden(user)
      if user.is_moderator?
        where("(score < ? and is_sticky = false) or is_deleted = true", user.comment_threshold)
      else
        where("score < ? and is_sticky = false", user.comment_threshold)
      end
    end

    def visible(user)
      if user.is_moderator?
        where("(score >= ? or is_sticky = true) and is_deleted = false", user.comment_threshold)
      else
        where("score >= ? or is_sticky = true", user.comment_threshold)
      end
    end

    def deleted
      where("comments.is_deleted = true")
    end

    def undeleted
      where("comments.is_deleted = false")
    end

    def post_tags_match(query)
      where(post_id: PostQueryBuilder.new(query).build.reorder(""))
    end

    def for_creator(user_id)
      user_id.present? ? where("creator_id = ?", user_id) : none
    end

    def for_creator_name(user_name)
      for_creator(User.name_to_id(user_name))
    end

    def search(params)
      q = super

      q = q.attribute_matches(:body, params[:body_matches], index_column: :body_index)

      if params[:post_id].present?
        q = q.where("post_id in (?)", params[:post_id].split(",").map(&:to_i))
      end

      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end

      if params[:creator_name].present?
        q = q.for_creator_name(params[:creator_name])
      end

      if params[:creator_id].present?
        q = q.for_creator(params[:creator_id].to_i)
      end

      q = q.attribute_matches(:is_deleted, params[:is_deleted])
      q = q.attribute_matches(:is_sticky, params[:is_sticky])
      q = q.attribute_matches(:do_not_bump_post, params[:do_not_bump_post])

      case params[:order]
      when "post_id", "post_id_desc"
        q = q.order("comments.post_id DESC, comments.id DESC")
      when "score", "score_desc"
        q = q.order("comments.score DESC, comments.id DESC")
      when "updated_at", "updated_at_desc"
        q = q.order("comments.updated_at DESC")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module VoteMethods
    def vote!(val)
      ckey = "cvote:#{CurrentUser.id}:#{id}"
      raise CommentVote::Error.new("You are already voting") if !Cache.get(ckey).nil?
      Cache.put(ckey, true, 30)
      CommentVote.transaction do
        numerical_score = val == "up" ? 1 : -1
        vote = votes.create(:score => numerical_score)

        if vote.invalid?
          Cache.delete(ckey)
          raise CommentVote::Error.new(vote.errors.full_messages.join(", "))
        end

        if vote.is_positive?
          update_column(:score, score + 1)
        elsif vote.is_negative?
          update_column(:score, score - 1)
        end

        Cache.delete(ckey)
        return vote
      end
    end

    def unvote!
      ckey = "cvote:#{CurrentUser.id}:#{id}"
      raise CommentVote::Error.new("You are already voting") if !Cache.get(ckey).nil?
      Cache.put(ckey, true, 30)
      CommentVote.transaction do
        vote = votes.where("user_id = ?", CurrentUser.user.id).first

        if vote
          if vote.is_positive?
            update_column(:score, score - 1)
          else
            update_column(:score, score + 1)
          end

          vote.destroy
        else
          Cache.delete(ckey)
          raise CommentVote::Error.new("You have not voted for this comment")
        end
      end
      Cache.delete(ckey)
    end
  end

  extend SearchMethods
  include VoteMethods

  def validate_post_exists
    errors.add(:post, "must exist") unless Post.exists?(post_id)
  end

  def validate_creator_is_not_limited
    if creator.is_comment_limited? && !do_not_bump_post?
      errors.add(:base, "You can only post #{Danbooru.config.member_comment_limit} comments per hour")
      false
    elsif creator.can_comment?
      true
    else
      errors.add(:base, "You can not post comments within 1 week of sign up")
      false
    end
  end

  def update_last_commented_at_on_create
    post = Post.find(post_id)
    return unless post
    post.update_column(:last_commented_at, created_at)
    if Comment.where("post_id = ?", post_id).count <= Danbooru.config.comment_threshold && !do_not_bump_post?
      post.update_column(:last_comment_bumped_at, created_at)
    end
    post.update_index
    true
  end

  def update_last_commented_at_on_destroy
    post = Post.find(post_id)
    return unless post
    other_comments = Comment.where("post_id = ? and id <> ?", post_id, id).order("id DESC")
    if other_comments.count == 0
      post.update_columns(:last_commented_at => nil)
    else
      post.update_columns(:last_commented_at => other_comments.first.created_at)
    end

    other_comments = other_comments.where("do_not_bump_post = FALSE")
    if other_comments.count == 0
      post.update_columns(:last_comment_bumped_at => nil)
    else
      post.update_columns(:last_comment_bumped_at => other_comments.first.created_at)
    end
    post.update_index
    true
  end

  def below_threshold?(user = CurrentUser.user)
    score < user.comment_threshold
  end

  def editable_by?(user)
    creator_id == user.id || user.is_moderator?
  end

  def visible_to?(user)
    is_deleted? == false || (creator_id == user.id || user.is_moderator?)
  end

  def hidden_attributes
    super + [:body_index]
  end

  def method_attributes
    super + [:creator_name, :updater_name]
  end

  def delete!
    update(is_deleted: true)
  end

  def undelete!
    update(is_deleted: false)
  end

  def quoted_response
    DText.quote(body, creator_name)
  end
end
