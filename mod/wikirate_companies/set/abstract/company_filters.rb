# This module is separated from CompanySearch so that it can be included in
# AnswerSearch without overriding key methods.

format do
  def shared_company_filter_map
    %i[company_category company_group country company_answer]
  end
end

format :html do
  # don't show advanced company answer filter in compact form
  def compact_filter_form_fields
    super.select { |hash| hash[:key] != :company_answer }
  end

  # def corporate_identifier_filter
  #
  # end

  # The following all help support the "advanced" filter for companies based on answers
  # (a list of constraints; the same ui used for specifying company groups)
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

  # value shown on closer badge for company answer filter
  def filter_company_answer_closer_value constraints
    Array.wrap(constraints).map do |c|
      bits = closer_constraint_bits c[:metric_id].to_i, c[:value],
                                    c[:related_company_group], c[:year]
      bits.compact.reject { |i| i == false }.join " "
    end.compact.join ", "
  end

  # fixes handling of certain requests that use $.params(json) and send the company
  # answer filter as { "0" => constraint1, "1" => constraint2... ...}
  def filter_hash
    super.tap do |hash|
      if hash[:company_answer].is_a? Hash
        hash[:company_answer] = hash[:company_answer].values
      end
    end
  end

  private

  def closer_constraint_bits metric_id, value, group, year
    [
      metric_id.card&.metric_title,
      (year.present? && "(#{year})"),
      (value.present? && filter_value_closer_value(value)),
      (group.present? && "[#{group}]")
    ]
  end
end

# note, ruby 3 handles things with just the first include_set.
# earlier rubies don't.
Abstract::AnswerSearch.include_set CompanyFilters
Abstract::FixedAnswerSearch.include_set CompanyFilters
Abstract::FullAnswerSearch.include_set CompanyFilters
