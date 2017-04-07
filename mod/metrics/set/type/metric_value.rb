card_accessor :value, type: :phrase

include_set Abstract::MetricChild, generation: 2

event :set_metric_value_name,
      before: :set_autoname, when: :invalid_value_name? do
  new_name = %w[metric company year].map do |part|
    fetch_name_part part
  end.join "+"
  abort :failure if errors.any?
  self.name = new_name
end

def filtered_item_query filter={}, sort={}, paging={}
  filter[:year] = year.to_i
  FixedMetricAnswerQuery.new metric_card.id, filter, sort, paging
end

def fetch_name_part part
  name_part = name_part_from_field(part) || name_part_from_name(part)
  check_name_part part, name_part
end

def name_part_from_name part
  return unless send("valid_#{part}?")
  send part
end

def name_part_from_field part
  field = remove_subfield part
  return unless field && field.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end

def answer
  @answer ||= Answer.find_by_answer_id id
end
