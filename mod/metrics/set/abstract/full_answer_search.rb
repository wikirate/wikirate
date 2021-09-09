include_set Abstract::BrowseFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::AnswerSearch

format do
  STANDARD_FILTER_KEYS = %i[
    status year metric_name company_name company_category company_group wikirate_topic
    value updated updater verification calculated metric_type value_type dataset source
    research_policy bookmark
  ].freeze

  def standard_filter_keys
    STANDARD_FILTER_KEYS
  end

  def default_filter_hash
    { company_name: "" }
  end
end

format :html do
  def details_view
    :details_sidebar
  end

  def details_layout
    :modal
  end

  def header_cells
    [company_sort_links, metric_sort_links, answer_sort_links]
  end

  def cell_views
    [:company_thumbnail_with_bookmark, :metric_thumbnail_with_bookmark, :concise]
  end

  def quick_filter_list
    @quick_filter_list ||=
      bookmark_quick_filter + topic_quick_filters + dataset_quick_filters
  end

  def bookmark_type
    :todo
  end

  # def bookmark_quick_filters
  #   return [] unless my_bookmarks?
  #
  #   %i[wikirate_company metric].map do |codename|
  #     { bookmark: :bookmark,
  #       text: "My #{codename.cardname} Bookmarks",
  #       class: "quick-filter-by-#{codename}" }
  #   end
  # end
end
