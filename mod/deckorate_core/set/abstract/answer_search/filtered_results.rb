include_set Abstract::FilteredBodyToggle
include_set Abstract::LazyTree

GROUP_SELECT = { answer_count: "count(distinct(answers.id))",
                 year: "max(year)",
                 year_count: "count(distinct(answers.year))" }.freeze

GROUP_SELECT_KEYS = {
  company: %i[answer_count year_count],
  metric: %i[answer_count year_count],
  record: %i[answer_count year]
}.freeze

format do
  def answer_page_fixed_filters
    card.query_hash
  end

  def answer_page_filters
    filter_hash.merge answer_page_fixed_filters
  end

  def default_grouping
    :none
  end

  def search_with_params
    return super if current_group == :none

    @search_results ||= {}
    @search_results[current_group] ||= Answer.connection.exec_query(group_by_query.to_sql)
  end

  def count_with_params
    @count_with_params ||=
      case current_group
      when :none
        counts[:metric_answer]
      when :company
        counts[:wikirate_company]
      when :metric
        counts[:metric]
      when :record
        count_query.lookup_relation.except(:select).select(group_by_fields).distinct.count
      end
  end

  def current_group
    item_view = implicit_item_view.to_s
    @current_group ||=
      if item_view.blank?
        default_grouping
      elsif (match = item_view.match(/(company|metric|record)/))
        match[1].to_sym
      else
        :none
      end
  end
end

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

  view :filtered_results_footer do
    super() + wrap_with("div", class: "text-end py-3") { answer_page_link }
  end

  view :core do
    with_sorting_and_wrapper do
      if current_group == :none
        super()
      else
        grouped_result
      end
    end
  end

  def answer_page_link
    link_to_card :metric_answer,
                 "View all answers #{icon_tag :east}",
                 path: { filter: answer_page_filters }
  end

  def default_filtered_body
    :core
  end

  def default_item_view
    :grouped_company
  end

  private

  def default_grouping
    :company
  end

  def customize_item_options
    { company: "Grouped by Company",
      metric: "Grouped by Metric",
      record: "Grouped by Company/Metric",
      none: "Individual Answers (No Grouping)" }
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
    return yield if current_group == :record && result["answer_count"] == 1

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
              filter: grouped_card_filter,
              slot: grouped_card_stub_slot_options
  end

  def grouped_card_filter
    filter_hash_from_params || {}
  end

  def grouped_card_stub_slot_options
    { hide: :sorting_header }
  end

  def with_sorting_and_wrapper
    haml :sorting_and_wrapper, results: yield
  end

  def group_by_fields_string
    group_by_fields.map { |fld| "answers.#{fld}" }.join ", "
  end

  def group_by_query
    group_by = select_fields = group_by_fields_string
    GROUP_SELECT_KEYS[current_group].each do |key|
      select_fields += ", #{GROUP_SELECT[key]} AS #{key}"
    end
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
