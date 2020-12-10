include_set Abstract::BrowseFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::AnswerSearch

format do
  def default_filter_hash
    { metric_name: "", company_name: "" }
  end

  def filter_keys
    %i[status year metric_name company_name company_group
       wikirate_topic value updated updater check calculated
       metric_type value_type project source research_policy bookmark]
  end

  def filter_label field
    field.to_sym == :metric_type ? "Metric type" : super
  end
end

format :html do
  def layout_name_from_rule
    :wikirate_one_full_column_layout
  end

  before :header do
    voo.title = "Answer Dashboard #{mapped_icon_tag :dashboard}"
    voo.variant = nil
  end

  view :titled_content do
    [field_nest(:description), render_filtered_content(items: { view: :bar })]
  end

  def details_view
    :details_sidebar
  end

  def header_cells
    [company_sort_links, metric_sort_links, answer_sort_links]
  end

  def cell_views
    [:company_thumbnail_with_bookmark, :metric_thumbnail_with_bookmark, :concise]
  end

  def quick_filter_list
    @quick_filter_list ||=
      bookmark_quick_filter + topic_quick_filters + project_quick_filters
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

format :json do
  def default_vega_options
    { layout: { width: 700 } }
  end
end
