include_set Abstract::BrowseFilterForm
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::AnswerSearch

def filter_keys
  %i[status year metric_name company_name company_group
     wikirate_topic check value updated calculated
     metric_type value_type project source research_policy bookmark]
end

def bookmark_type
  :metric
end

def record?
  false # TODO: detect records
end

format :html do
  before :core do
    voo.hide! :chart
  end

  def default_filter_hash
    { status: :exists, year: :latest, metric_name: "", company_name: "" }
  end

  def details_view
    :metric_details_sidebar
  end

  def header_cells
    %w[Metric Company Answer]
  end

  def cell_views
    [:metric_thumbnail_with_bookmark, :company_thumbnail_with_bookmark, :concise]
  end

  def filter_label field
    field.to_sym == :metric_type ? "Metric type" : super
  end

  def quick_filter_list
    @quick_filter_list ||=
      Card.fetch(:metric, :browse_metric_filter).format.quick_filter_list
  end
end
