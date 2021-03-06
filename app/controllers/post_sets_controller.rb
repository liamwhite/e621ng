class PostSetsController < ApplicationController
  respond_to :html, :json, :xml
  before_action :member_only, only: [:new, :create, :update, :destroy,
                                     :edit, :maintainers, :update_posts,
                                     :add_post, :remove_post]

  def index
    if !params[:post_id].blank?
      if CurrentUser.is_admin?
        @sets = PostSet.paginate(include: :set_entries, conditions: ["set_entries.post_id = ?", params[:post_id]], page: 1, per_page: 50)
      else
        @sets = PostSet.paginate(include: :set_entries, conditions: ["(post_sets.public = TRUE OR post_sets.user_id = ?) AND set_entries.post_id = ?", CurrentUser.id || 0, params[:post_id]], page: 1, per_page: 50)
      end
    elsif !params[:maintainer_id].blank?
      if CurrentUser.is_admin?
        @sets = PostSet.paginate(include: :set_maintainers, conditions: ["(set_maintainers.user_id = ? AND set_maintainers.status = 'approved')", params[:maintainer_id]], page: 1, per_page: 50)
      else
        @sets = PostSet.paginate(include: :set_maintainers, conditions: ["(post_sets.public = TRUE OR post_sets.user_id = ?) AND (set_maintainers.user_id = ? AND set_maintainers.status = 'approved')", CurrentUser.id || 0, params[:maintainer_id]], page: 1, per_page: 50)
      end
    else
      @sets = PostSet.search(search_params).paginate(params[:page], limit: params[:limit])
    end

    respond_with(@sets)
  end

  def atom
    begin
      @sets = PostSet.visible.order(id: :desc).limit(32)
      headers["Content-Type"] = "application/atom+xml"
    rescue RuntimeError => e
      @set = []
    end

    render layout: false
  end

  def new
    @set = PostSet.new
  end

  def create
    @set = PostSet.create(set_params)
    flash[:notice] = @set.valid? ? 'Set created' : @set.errors.full_messages.join('; ')
    respond_with(@set)
  end

  def show
    @set = PostSet.find(params[:id])
    check_view_access(@set)

    respond_with(@set)
  end

  def edit
    @set = PostSet.find(params[:id])
    check_edit_access(@set)
    @can_edit = @set.is_owner?(CurrentUser) || CurrentUser.is_admin?
    respond_with(@set)
  end

  def update
    @set = PostSet.find(params[:id])
    check_edit_access(@set)
    @set.update(set_params)
    flash[:notice] = @set.valid? ? 'Set updated.' : @set.errors.full_messages.join('; ')

    if CurrentUser.is_admin? && !@set.is_owner?(CurrentUser.user)
      if @set.saved_change_to_is_public?
        ModAction.log("User ##{CurrentUser.id} marked set ##{@set.id} as private", :set_mark_private)
      end

      if @set.saved_change_to_watched_attribute?
        ModAction.log("Admin ##{CurrentUser.id} edited set ##{@set.id}", :set_edit)
      end
    end

    respond_with(@set)
  end

  def maintainers
    @set = PostSet.find(params[:id])
  end

  def post_list
    @set = PostSet.find(params[:id])
    check_edit_access(@set)
    respond_with(@set)
  end

  def update_posts
    @set = PostSet.find(params[:id])
    check_edit_access(@set)
    @set.update(update_posts_params)
    flash[:notice] = @set.valid? ? 'Set posts updated.' : @set.errors.full_messages.join('; ')

    redirect_back(fallback_location: post_list_post_set_path(@set))
  end

  def destroy
    @set = PostSet.find(params[:id])
    unless @set.is_owner?(CurrentUser.user) || CurrentUser.is_admin?
      raise User::PrivilegeError
    end
    @set.destroy
    respond_with(@set)
  end

  def select
    @sets_owned = PostSet.all(order: "lower(name) ASC", conditions: ["user_id = ?", CurrentUser.id])
    @sets_maintained = SetMaintainer.all(joins: :post_set, select: "set_maintainers.*, post_sets.*", conditions: ["set_maintainers.user_id = ? AND post_sets.public = TRUE", CurrentUser.id])

    @grouped_options = {
        "Owned" => @sets_owned.map {|x| [truncate(x.name.tr("_", " "), length: 35), x.id]},
        "Maintained" => @sets_maintained.map {|x| [truncate(x.name.tr("_", " "), length: 35), x.id]}
    }

    render layout: false
  end

  def add_posts
    @set = PostSet.find(params[:set_id])
    check_edit_access(@set)
    @set.add(params[:post_ids])
    @set.save
    respond_with(@set)
  end

  def remove_post
    @set = PostSet.find(params[:set_id])
    check_edit_access(@set)
    @set.remove(params[:post_ids])
    @set.save
    respond_with(@set)
  end

  private

  def check_edit_access(set)
    unless set.is_owner?(CurrentUser.user) || set.is_maintainer?(CurrentUser.user)
      raise User::PrivilegeError
    end
    if !set.is_public && !set.is_owner?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end

  def check_view_access(set)
    unless set.is_public || set.is_owner?(CurrentUser.user) || CurrentUser.is_admin?
      raise User::PrivilegeError
    end
  end

  def set_params
    params.require(:post_set).permit(%i[name shortname description is_public transfer_on_delete])
  end

  def update_posts_params
    params.require(:post_set).permit([:post_ids_string])
  end

  def search_params
    params.fetch(:search, {}).permit!
  end
end
