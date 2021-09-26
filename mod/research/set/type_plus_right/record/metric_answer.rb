include_set Abstract::MetricChild, generation: 2

include_set Abstract::AnswerSearch
include_set Abstract::Chart

def query_hash
  { company_id: company_id, metric_id: metric_id }
end

format do
  def standard_filter_keys
    %i[status year value updated updater verification calculated dataset source]
  end

  def default_filter_hash
    { year: nil }
  end

  def default_sort_option
    :year
  end
end

format :html do
  def cell_views
    [:concise]
  end

  def header_cells
    [answer_sort_links]
  end

  def details_view
    :details_sidebar
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
