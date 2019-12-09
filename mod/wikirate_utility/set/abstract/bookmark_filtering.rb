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
  Bookmark.current_bookmarks[Card.fetch_id(bookmark_type)].present?
end

format do
  delegate :bookmark_type, :my_bookmarks?, to: :card
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
    quick_filters_for :wikirate_topic, :homepage_featured_topics
  end

  def company_group_quick_filters
    quick_filters_for :company_group, %i[company_group featured]
  end

  def quick_filters_for type_code, featured
    filter_names_for(type_code, featured).map do |name|
      { type_code => name }
    end
  end

  def filter_names_for type_code, featured
    ids = Bookmark.current_bookmarks[Card::Codename.id(type_code)]
    if ids.present?
      ids.map(&:cardname).compact
    else
      Card[featured].item_names
    end
  end
end
