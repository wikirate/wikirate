format :html do
  before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_header do
    [super(), (render_filtered_results_chart if show_chart?)].compact
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

  def export_formats
    %i[csv json]
  end

  def extra_paging_path_args
    @extra_paging_path_args ||= super.merge sort_by: sort_by, sort_dir: sort_dir
  end
end
