class TagCloud
# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

  attr_reader :user

  def initialize(user, cut_off = nil)
    @user    = user
    @cut_off = cut_off
  end

  def min
    0
  end

  def max
    tag_counts.max
  end

  def divisor
    @divisor ||= ((max - min) / levels) + 1
  end

  def tag_counts
    @tag_counts ||= tags.map { |t| t.count.to_i }
  end

  def tags
    unless @tags
      params = [sql(@cut_off), user.id]
      if @cut_off
        params += [@cut_off, @cutoff]
      end
      @tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
    end

    @tags
  end

  private

  # TODO: parameterize limit
  def levels
    10
  end

  def sql(cut_off = nil)
    query = "SELECT tags.id, tags.name AS name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND todos.user_id=? "
    query << " AND taggings.taggable_type='Todo' "
    query << " AND taggings.taggable_id=todos.id "
    if cut_off
      query << " AND (todos.created_at > ? OR "
      query << "      todos.completed_at > ?) "
    end
    query << " GROUP BY tags.id, tags.name"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
  end
end
