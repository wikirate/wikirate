def filter_keys
  [:bookmark]
end

def default_sort_option
  :bookmarkers
end

format :html do
  def sort_options
    { "Most Bookmarked": :bookmarkers }.merge super
  end

  def quick_filter_list
    bookmark_quick_filter
  end

  def bookmark_quick_filter
    return [] unless current_bookmarks_of_type(bookmark_type).present?

    [{ bookmark: :bookmark,
       text: "My Bookmarks",
       class: "quick-filter-by-#{bookmark_type}" }]
  end

  def topic_quick_filters
    topic_names = current_bookmark_names_of_type :wikirate_topic
    topic_names = featured_topic_names unless topic_names.present?
    topic_names.map { |topic| { wikirate_topic: topic } }
  end

  def featured_topic_names
    Card[:homepage_featured_topics].item_names
  end

  def bookmark_type
    card.name.left.downcase
  end
end
