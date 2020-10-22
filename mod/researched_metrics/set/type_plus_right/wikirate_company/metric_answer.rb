# Answer search for a given Company
include_set Abstract::FilterFormgroups
include_set Abstract::MetricFilterFormgroups
include_set Abstract::BookmarkFiltering
include_set Abstract::SdgFiltering
include_set Abstract::CachedCount
include_set Abstract::AnswerSearch
include_set Abstract::FixedAnswerSearch

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  changed_card.company_card&.fetch :metric_answer
end
# TODO: trigger recount from virtual answer batches

def fixed_field
  :company_id
end

def partner
  :metric
end

def bookmark_type
  :metric
end

format do
  def filter_keys
    %i[status year metric_name wikirate_topic value updated updater check calculated
     metric_type value_type project source research_policy bookmark]
  end

  def default_sort_option
    record? ? :year : :bookmarkers
  end

  def default_filter_hash
    { status: :exists, year: :latest, metric_name: "" }
  end
end

format :html do
  before :core do
    voo.hide! :chart
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
    table_sort_link "Metric", :metric_title, "pull-left mx-3 px-1"
  end

  def designer_sort_link
    table_sort_link "", :metric_designer, "pull-left mx-3 px-1"
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
