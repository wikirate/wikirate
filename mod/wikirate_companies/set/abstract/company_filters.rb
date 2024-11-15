# This module is separated from CompanySearch so that it can be included in
# RecordSearch without overriding key methods.

format do
  def shared_company_filter_map
    %i[company_identifier company_category company_group country company_record]
  end

  # fixes handling of certain requests that use $.params(json) and send the company
  # record filter as { "0" => constraint1, "1" => constraint2... ...}
  def filter_hash
    super.tap do |hash|
      ans = hash[:company_record]
      hash[:company_record] = ans.values if ans.is_a?(Hash) && ans.keys.first == "0"
    end
  end
end

format :html do
  # don't show advanced company record filter in compact form
  def compact_filter_form_fields
    super.select { |hash| hash[:key] != :company_record }
  end

  def filter_company_identifier_type
    :identifier_custom
  end

  def identifier_custom_filter field, _config
    haml :identifier_custom_filter, defaults: (filter_param(field) || {})
  end

  def filter_company_identifier_closer_value cid
    vals = [cid[:value]]
    if cid[:type].present?
      type_list = Array.wrap(cid[:type]).join ", "
      vals.unshift "(#{type_list})"
    end
    vals.join " "
  end

  # The following all help support the "advanced" filter for companies based on records
  # (a list of constraints; the same ui used for specifying company groups)
  def filter_company_record_type
    :company_record_custom
  end

  def filter_company_record_label
    "Advanced"
  end

  def company_record_custom_filter _field, _config
    editor_wrap :content do
      subformat(card.field(:specification)).constraint_list_input
    end
  end

  # value shown on closer badge for company record filter
  def filter_company_record_closer_value constraints
    Array.wrap(constraints).map do |c|
      bits = closer_constraint_bits c[:metric_id].to_i, c[:value],
                                    c[:related_company_group], c[:year]
      bits.compact.reject { |i| i == false }.join " "
    end.compact.join ", "
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
Abstract::RecordSearch.include_set CompanyFilters
Abstract::FixedRecordSearch.include_set CompanyFilters
Abstract::FullRecordSearch.include_set CompanyFilters
