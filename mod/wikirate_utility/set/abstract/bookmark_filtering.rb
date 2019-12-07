def filter_keys
  [:bookmark]
end

def default_sort_option
  :bookmarkers
end

def bookmark_type
  name.left.downcase
end

def my_bookmarks?
  current_bookmarks[Card.fetch_id(bookmark_type)].present?
end


format do
  delegate :bookmark_type, :current_bookmarks, :my_bookmarks?, to: :card
end

format :html do
  def sort_options
    { "Most Bookmarked": :bookmarkers }.merge super
  end

  def quick_filter_list
    bookmark_quick_filter
  end

  def bookmark_quick_filter
    return [] unless my_bookmarks?

    [{ bookmark: :bookmark,
       text: "My Bookmarks",
       class: "quick-filter-by-#{bookmark_type}" }]
  end

  def topic_quick_filters
    topic_filter_names.map { |topic| { wikirate_topic: topic } }
  end

  def topic_filter_names
    topic_ids = current_bookmarks[WikirateTopicID]
    if topic_ids.present?
      topic_ids.map(&:cardname).compact
    else
      featured_topic_names
    end
  end

  def featured_topic_names
    Card[:homepage_featured_topics].item_names
  end
end
