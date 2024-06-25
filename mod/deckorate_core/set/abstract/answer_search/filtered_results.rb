include_set Abstract::FilteredBodyToggle
include_set Abstract::LazyTree

GROUPED = { answer_count: "count(*)",
            year_count: "count(distinct(year))" }.freeze

format :html do
  # before(:compact_filter_form) { voo.hide :filter_sort_dropdown }

  view :filtered_results_stats, cache: :never, template: :haml
  view :filtered_results_chart, cache: :never, template: :haml
  view :customize_filtered_panel, template: :haml
  view :customize_filtered_button, template: :haml
  view :sorting_header, template: :haml, cache: :never

  view :filtered_results_nav do
    [render_filtered_body_toggle]
  end

  view :core do
    with_sorting do
      if current_group == :none
        super()
      else
        grouped_result
      end
    end
  end

  def search_with_params
    return super if current_group == :none

    @search_results ||= {}
    @search_results[current_group] ||=
      Answer.connection.exec_query(
        group_by_query(:"#{current_group}_id").to_sql
      )
  end

  def current_group
    item_view = implicit_item_view.to_s
    @current_group ||=
      if item_view.blank? || item_view.match?(/company/)
        :company
      elsif item_view.match?(/metric/)
        :metric
      else
        :none
      end
  end

  def count_with_params
    return super if current_group == :none

    count_query
      .lookup_relation
      .except(:select)
      .select("distinct(#{current_group}_id)").count
  end

  def grouped_result
    with_paging do
      search_with_params.map do |result|
        result_id = result["#{current_group}_id"]
        tree_item haml(:"grouped_#{current_group}", result),
                  body: grouped_card_stub(result_id),
                  context: result_id
      end
    end
  end

  def grouped_card_stub base_id
    card_stub mark: [base_id, :metric_answer],
              filter: params[:filter]&.to_unsafe_h || {},
              slot: { hide: :sorting_header }
  end

  def with_sorting
    output [render_sorting_header(optional: :show), yield]
  end

  def group_by_query group_by_field
    select_fields = "answers.#{group_by_field.to_s}"
    GROUPED.each { |k, v| select_fields += ", #{v} AS #{k}" }
    query.lookup_relation.except(:select).select(select_fields).group(group_by_field)
  end

  def default_sort_option
    current_group == :none ? :year : :answer_count
  end

  def filtered_body_views
    show_chart? ? { core: :bars, filtered_results_chart: :graph } : {}
  end

  def default_filtered_body
    :core
  end

  def default_item_view
    :grouped_company
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
