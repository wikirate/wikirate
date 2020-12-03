include_set Abstract::BrowseFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::AnswerSearch

def bookmark_type
  :metric
end

format do
  def default_filter_hash
    { status: :exists, metric_name: "", company_name: "" }
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
  def details_view
    :metric_details_sidebar
  end

  def header_cells
    %w[Metric Company Answer]
  end

  def cell_views
    [:metric_thumbnail_with_bookmark, :company_thumbnail_with_bookmark, :concise]
  end

  def quick_filter_list
    @quick_filter_list ||=
      Card.fetch(:metric, :browse_metric_filter).format.quick_filter_list
  end
end

format :json do
  def vega
    type = chart_type
    options = try("#{type}_options") || {}
    options[:layout] ||= { width: 700 }
    VegaChart.new chart_type, self, options
  end

  def chart_type
    if (type = params[:chart])
      type.to_sym
    elsif filter_hash[:year]
      single_year_chart_type
    else
      :timeline
    end
  end

  def grid_options
    (40 - metric_count).abs > (40 - company_count).abs ? { invert: true } : {}
  end

  def single_year_chart_type
    metric_count > 70 || company_count > 70 ? :pie : :grid
  end
end
