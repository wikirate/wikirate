include_set Abstract::DeckorateFiltering
include_set Abstract::CommonFilters
include_set Abstract::BookmarkFiltering
include_set Abstract::LookupSearch
include_set Abstract::SearchViews

def bookmark_type
  :metric
end

def item_type
  "Metric"
end

def filter_class
  MetricQuery
end

def target_type_id
  MetricID
end

format do
  def default_filter_hash
    { name: "" }
  end

  def default_limit
    Auth.signed_in? ? 5000 : 500
  end

  def default_sort_option
    :bookmarkers
  end

  # TODO: bookmarking
  def shared_metric_filter_map
    %i[wikirate_topic designer metric_type value_type research_policy]
  end

  def filter_map
    filtering_by_published do
      shared_metric_filter_map.unshift key: :name, open: true
    end << :dataset
  end

  def sort_options
    {
      "Most Bookmarked": :bookmarkers,
      "Most Companies": :company,
      "Most Answers": :answer,
      "Designer": :metric_designer,
      "Title": :metric_title
    }
  end

  def default_desc_sort_dir
    ::Set.new %i[bookmarkers company answer]
  end
end

format :html do
  METRIC_FILTER_TYPES = {
    metric_name: :text,
    research_policy: :radio,
    metric_type: :check,
    designer: :check,
    value_type: :check
  }.freeze

  METRIC_FILTER_TYPES.each do |filter_key, filter_type|
    define_method("filter_#{filter_key}_type") { filter_type }
  end

  def filter_designer_options
    Card.cache.fetch "METRIC-DESIGNER-OPTIONS" do
      metrics = Card.search type_id: MetricID, return: :name
      metrics.map do |m|
        names = m.to_name.parts
        # score metric?
        names.length == 3 ? names[2] : names[0]
      end.uniq(&:downcase).sort_by(&:downcase)
    end
  end

  def filter_metric_type_options
    %i[researched relationship inverse_relationship formula wiki_rating score descendant]
      .map(&:cardname)
  end

  def filter_research_policy_options
    type_options :research_policy
  end

  def filter_value_type_options
    Card.cache.fetch "VALUE-TYPE-OPTIONS" do
      options = Card[:metric, :value_type, :type_plus_right, :content_options].item_names
      options.map(&:to_s)
    end.map(&:to_name)
  end

  def filter_value_type_label
    "Value Type"
  end

  def filter_metric_type_label
    "Metric Type"
  end

  def export_formats
    [:csv, :json]
  end

  def quick_filter_list
    bookmark_quick_filter + topic_quick_filters + dataset_quick_filters
  end
end

format :csv do
  view :core do
    rows = search_with_params.map { |ic| nest ic, view: :line }
    rows.unshift(header).join
  end

  def header
    CSV.generate_line MetricImportItem.headers
  end
end
