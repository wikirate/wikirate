include_set Abstract::FilteredBodyToggle
include_set Abstract::LazyTree

GROUPED = { answer_count: "count(distinct(answers.id))",
            latest_year: "max(year)",
            year_count: "count(distinct(answers.year))" }.freeze

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
    @search_results[current_group] ||= Answer.connection.exec_query(group_by_query.to_sql)
  end

  def count_with_params
    return super if current_group == :none

    count_query
      .lookup_relation
      .except(:select)
      .select(group_by_fields).distinct.count
  end

  def default_sort_option
    current_group == :none ? :year : :answer_count
  end

  def default_filtered_body
    :core
  end

  def default_item_view
    :grouped_company
  end

  private

  def current_group
    item_view = implicit_item_view.to_s
    @current_group ||=
      if item_view.blank? || item_view.match?(/company/)
        :company
      elsif item_view.match?(/metric/)
        :metric
      elsif item_view.match?(/record/)
        :record
      else
        :none
      end
  end

  def grouped_result
    with_paging do
      search_with_params.map do |result|
        result[:name] = grouped_result_name result
        branching_results(result) { haml(:"grouped_#{current_group}", result) }
      end
    end
  end

  def branching_results result
    return yield if current_group == :record && result["year_count"] == 1

    tree_item yield, body: grouped_card_stub(result[:name]),
              context: result[:name].safe_key
  end

  def grouped_result_name result
    group_by_fields.map { |fld| result[fld] }.cardname
  end

  # def record_result result
  #   Card.fetch
  # end

  def group_by_fields
    if current_group == :record
      %w[metric_id company_id]
    else
      ["#{current_group}_id"]
    end
  end

  def grouped_card_stub base_name
    card_stub mark: [base_name, :metric_answer],
              filter: params[:filter]&.to_unsafe_h || {},
              slot: grouped_card_stub_slot_options
  end

  def grouped_card_stub_slot_options
    { hide: :sorting_header }
  end

  def with_sorting
    output [render_sorting_header(optional: :show), yield]
  end

  def group_by_fields_string
    group_by_fields.map { |fld| "answers.#{fld}" }.join ", "
  end

  def group_by_query
    group_by = select_fields = group_by_fields_string
    GROUPED.each { |k, v| select_fields += ", #{v} AS #{k}" }
    query.lookup_relation.except(:select).select(select_fields).group group_by
  end

  def filtered_body_views
    show_chart? ? { core: :bars, filtered_results_chart: :graph } : {}
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
