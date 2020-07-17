# Answer search for a given Company
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::AnswerSearch
include_set Abstract::FixedAnswerSearch

def filter_keys
  %i[status year metric_name wikirate_topic value updated updater check calculated
     metric_type value_type project source research_policy bookmark]
end

def bookmark_type
  :metric
end

def fixed_field
  :company_id
end

def filter_card_fieldcode
  :company_metric_filter
end

def default_sort_option
  record? ? :year : :bookmarkers
end

def partner
  :metric
end

format :html do
  before :core do
    voo.hide! :chart
  end

  def default_filter_hash
    { status: :exists, year: :latest, metric_name: "" }
  end

  def cell_views
    [:metric_thumbnail_with_bookmark, :concise]
  end

  def header_cells
    [name_sort_links, render_answer_header]
  end

  def details_view
    :metric_details_sidebar
  end

  def name_sort_links
    "#{bookmarkers_sort_link}#{designer_sort_link}#{title_sort_link}"
  end

  def title_sort_link
    table_sort_link "Metric", :title_name, "pull-left mx-3 px-1"
  end

  def designer_sort_link
    table_sort_link "", :metric_name, "pull-left mx-3 px-1"
  end

  def bookmarkers_sort_link
    table_sort_link "", :bookmarkers, "pull-left mx-3 px-1"
  end

  def filter_label field
    field.to_sym == :metric_type ? "Metric type" : super
  end

  def quick_filter_list
    @quick_filter_list ||=
      Card.fetch(:metric, :browse_metric_filter).format.quick_filter_list
  end
end
