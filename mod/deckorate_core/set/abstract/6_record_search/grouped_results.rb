GROUP_SELECT = { record_count: "count(distinct(records.id))",
                 year: "max(records.year)",
                 value: "max(records.value)",
                 year_count: "count(distinct(records.year))" }.freeze

GROUP_SELECT_KEYS = {
  company: %i[record_count year_count],
  metric: %i[record_count year_count],
  record_log: %i[record_count value year]
}.freeze

format do
  def default_grouping
    :none
  end

  def current_group
    item_view = implicit_item_view.to_s
    @current_group ||= {}
    @current_group[item_view] ||=
      if item_view.blank?
        default_grouping
      elsif (match = item_view.match(/(company|metric|record_log)/))
        match[1].to_sym
      else
        :none
      end
  end
end

format :html do
  private

  def default_grouping
    :company
  end

  def grouped_result
    with_paging do
      search_with_params.map do |result|
        result[:name] = grouped_result_name result
        branching_results(result) { haml(:"grouped_#{current_group}", result) }
      end
    end
  end

  def grouped_result_name result
    group_by_fields.map { |fld| result[fld] }.cardname
  end

  def group_by_fields
    if current_group == :record_log
      %w[metric_id company_id]
    else
      ["#{current_group}_id"]
    end
  end

  def grouped_card_stub base_name
    card_stub mark: [base_name, :record],
              filter: grouped_card_filter,
              slot: grouped_card_stub_slot_options,
              limit: 5
  end

  def grouped_card_filter
    record_page_filters
  end

  def grouped_card_stub_slot_options
    { hide: :sorting_header }
  end

  def group_by_fields_string
    group_by_fields.map { |fld| "records.#{fld}" }.join ", "
  end

  def group_by_query
    group_by = select_fields = group_by_fields_string
    GROUP_SELECT_KEYS[current_group].each do |key|
      select_fields += ", #{GROUP_SELECT[key]} AS #{key}"
    end
    clean_relation.select(select_fields).group group_by
  end

  def branching_results result
    return yield if current_group == :record_log && result["record_count"] == 1

    name = result[:name]
    tree_item yield, body: grouped_card_stub(name), context: name.safe_key
  end

  def record_log_sample_record metric_id, company_id, year, value
    if sort_param == "value"
      latest_record_with_value metric_id, company_id, value
    else
      Card.fetch [metric_id, company_id, year.to_s], new: {}
    end
  end

  def latest_record_with_value metric_id, company_id, value
    ::Record.where(metric_id: metric_id, company_id: company_id, value: value)
          .order(year: :desc).take.card
  end
end
