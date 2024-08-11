include_set Abstract::MetricChild, generation: 2

include_set Abstract::AnswerSearch
include_set Abstract::Chart

def query_hash
  { company_id: company_id, metric_id: metric_id }
end

format do
  def default_filter_hash
    { year: nil }
  end

  def default_sort_option
    :year
  end

  def answer_page_fixed_filters
    { company: card.company_id.cardname, metric: card.metric_id.cardname }
  end
end

format :html do
  before :core do
    voo.items[:hide] = %i[company_thumbnail metric_thumbnail]
  end

  def default_item_view
    :full_bar
  end

  def cell_views
    [:concise]
  end

  def header_cells
    [answer_sort_links]
  end

  def quick_filter_list
    []
  end

  # none and all not available on answer dashboard yet.
  # def status_options
  #   super.merge "Not Researched" => "none", "Researched and Not" => "all"
  # end

  # def show_company_count?
  #   false
  # end
  #
  # def show_metric_count?
  #   false
  # end
end
