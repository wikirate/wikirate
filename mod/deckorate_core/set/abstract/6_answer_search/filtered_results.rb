include_set Abstract::FilteredBodyToggle
include_set Abstract::LazyTree

format do
  def answer_page_fixed_filters
    card.query_hash
  end

  def answer_page_filters
    filter_hash.merge answer_page_fixed_filters
  end

  def search_with_params
    return super if current_group == :none

    @search_results ||= {}
    @search_results[current_group] ||=
      ::Answer.connection.exec_query(group_by_query.to_sql)
  end

  def count_with_params
    @count_with_params ||=
      case current_group
      when :none
        counts[:answer]
      when :company
        counts[:company]
      when :metric
        counts[:metric]
      when :record
        clean_relation(count_query).select(group_by_fields_string).distinct.count
      end
  end

  def clean_relation qry=nil
    (qry || query).lookup_relation.unscope(:select).unscope(:order)
  end
end

format :html do
  # before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_stats, cache: :never, template: :haml
  view :filtered_results_chart, cache: :never, template: :haml
  view :customize_filtered_panel, template: :haml, wrap: :slot
  view :customize_filtered_button, template: :haml
  view :sorting_header, template: :haml, cache: :never

  # before :filtered_results wasn't working...
  view :filtered_results do
    voo.items = params[:filter_items].to_unsafe_h.symbolize_keys if params[:filter_items]
    super()
  end

  view :filtered_results_nav do
    [render_filtered_body_toggle]
  end

  view :filtered_results_footer do
    super() + wrap_with("div", class: "text-end py-3") { answer_page_link }
  end

  view :core, cache: :never do
    with_sorting_and_wrapper do
      if current_group == :none
        super()
      else
        grouped_result
      end
    end
  end

  def slot_options
    super.tap do |options|
      options[:items] = voo.items if voo.items.present?
    end
  end

  def answer_page_link
    link_to_card :answer,
                 "View all datapoints #{icon_tag :east}",
                 path: { filter: answer_page_filters }
  end

  def default_filtered_body
    :core
  end

  def default_item_view
    :grouped_company
  end

  def scrollable?
    current_group.in? %i[none record]
  end

  private

  def with_sorting_and_wrapper
    haml :sorting_and_wrapper, results: yield
  end

  def customize_item_options
    { company: "Grouped by Company",
      metric: "Grouped by Metric",
      record: "Grouped by Company/Metric",
      none: "Data Points (No Grouping)" }
  end

  def show_hide_fields
    {
      headquarters: "Company Headquarters",
      identifiers: "Company Identifiers",
      metric_type: "Metric Type",
      metric_designer: "Metric Designer",
      contributor: "Contributor"
    }
  end

  def filtered_body_views
    return {} unless show_chart?

    { core: { icon: :bars, title: "List" },
      filtered_results_chart: { icon: :graph, title: "Graph" } }
  end

  before :filtered_results do
    class_up "card-slot", "_card-link-modal"
  end

  def filter_buttons
    super.insert 1, :customize_filtered_button
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
