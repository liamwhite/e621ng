class RelatedTagCalculator
  MAX_RESULTS = 25

  def self.calculate_from_sample_to_array(tags, category_constraint = nil)
    convert_hash_to_array(calculate_from_sample(tags, Danbooru.config.post_sample_size, category_constraint))
  end

  def self.calculate_from_posts_to_array(posts)
    convert_hash_to_array(calculate_from_posts(posts))
  end

  def self.calculate_from_posts(posts)
    counts = Hash.new {|h, k| h[k] = 0}

    posts.flat_map(&:tag_array).each do |tag|
      counts[tag] += 1
    end

    counts
  end

  def self.calculate_similar_from_sample(tag)
    # this uses cosine similarity to produce more useful
    # related tags, but is more db intensive
    counts = Hash.new {|h, k| h[k] = 0}

    CurrentUser.without_safe_mode do
      Post.with_timeout(5_000, [], {:tags => tag}) do
        Post.tag_match(tag).limit(400).reorder("posts.md5").pluck(:tag_string).each do |tag_string|
          tag_string.split.each do |tag|
            counts[tag] += 1
          end
        end
      end
    end

    tag_record = Tag.find_by_name(tag)
    candidates = convert_hash_to_array(counts, 100)
    similar_counts = Hash.new {|h, k| h[k] = 0}
    CurrentUser.without_safe_mode do
      Post.with_timeout(5_000, nil, {:tags => tag}) do
        candidates.each do |ctag, _|
          acount = Post.tag_match("#{tag} #{ctag}").count
          ctag_record = Tag.find_by_name(ctag)
          div = Math.sqrt(tag_record.post_count * ctag_record.post_count)
          if div != 0
            c = acount / div
            similar_counts[ctag] = c
          end
        end
      end
    end

    convert_hash_to_array(similar_counts)
  end

  def self.calculate_from_sample(tags, sample_size, category_constraint = nil, max_results = MAX_RESULTS)
    Post.with_timeout(5_000, [], {:tags => tags}) do
      sample = Post.sample(tags, sample_size)
      posts_with_tags = Post.from(sample).with_unflattened_tags

      if category_constraint
        posts_with_tags = posts_with_tags.joins("JOIN tags ON tags.name = tag").where("tags.category" => category_constraint)
      end

      counts = posts_with_tags.order("count_all DESC").limit(max_results).group("tag").count(:all)
      counts
    end
  end

  def self.convert_hash_to_array(hash, limit = MAX_RESULTS)
    hash.to_a.sort_by {|x| [-x[1], x[0]] }.slice(0, limit)
  end

  def self.convert_hash_to_string(hash)
    convert_hash_to_array(hash).flatten.join(" ")
  end
end
