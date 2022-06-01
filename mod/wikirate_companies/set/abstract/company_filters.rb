format do
  def filter_map
    shared_company_filter_map.unshift key: :name, open: true
  end

  def shared_company_filter_map
    %i[company_category company_group country company_answer]
  end
end

format :html do
  # don't show advanced company answer filter in compact form
  def compact_filter_form_fields
    super.select { |hash| hash[:key] != :company_answer }
  end

  def filter_company_answer_type
    :company_answer_custom
  end

  def filter_company_answer_label
    "Advanced"
  end

  def company_answer_custom_filter _field, _default, _opts
    editor_wrap :content do
      subformat(card.field(:specification)).constraint_list_input
    end
  end

  def filter_company_answer_closer_value constraints
    Array.wrap(constraints).map do |c|
      bits = closer_constraint_bits c[:metric_id].to_i, c[:value], c[:group], c[:year]
      bits.compact.join " "
    end.join ", "
  end

  private

  def closer_constraint_bits metric_id, value, group, year
    [
      metric_id.card&.metric_title,
      "—",
      (value.present? && filter_value_closer_value(value)),
      (group.present? && group),
      (year.present? && "(#{year})")
    ]
  end
end

Abstract::AnswerSearch.include_set CompanyFilters