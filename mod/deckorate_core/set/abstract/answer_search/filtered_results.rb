format :html do
  # before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_nav do
    [render_filter_sort_dropdown, render_filtered_body_toggle]
  end

  view :filtered_body_toggle do
    "(view toggle)"
  end

  view :filtered_results_visualization do
    return "" unless show_chart?

    render_filtered_results_chart
  end

  view :filtered_results_stats, cache: :never, template: :haml
  view :filtered_results_chart, cache: :never, template: :haml

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
