include_set Abstract::FilteredBodyToggle

format :html do
  # before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_stats, cache: :never, template: :haml
  view :filtered_results_chart, cache: :never, template: :haml

  view :grouped_by_company do
    each_grouped_company do |company_result|
      haml :grouped_company, company_result
    end
  end

  def each_grouped_company
    Answer.connection.exec_query(group_by_query.to_sql).map do |hash|
      yield hash
    end
  end

  def default_sort_option
    :company_name
  end

  def group_by_query
    query.lookup_relation
         .except(:select)
         .select("company_id, count(*) as answer_count, count(distinct(year)) as year_count")
         .group(:company_id)
  end

  def filtered_body_views
    show_chart? ? { core: :bars, filtered_results_chart: :graph } : {}
  end

  def default_filtered_body
    :grouped_by_company
  end

  before :filtered_results do
    class_up "card-slot", "_card-link-modal"
  end

  def show_company_count?
    true
  end

  def show_metric_count?
    true
  end

  def extra_paging_path_args
    @extra_paging_path_args ||= super.merge sort_by: sort_by, sort_dir: sort_dir
  end
end
