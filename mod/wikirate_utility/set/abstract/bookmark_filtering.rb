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
    [{ bookmark: :bookmark,
       text: "My Bookmarks",
       class: "quick-filter-by-#{bookmark_type}" }] + super
  end

  def bookmark_type
    card.name.left.downcase
  end
end
