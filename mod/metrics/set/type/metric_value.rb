card_accessor :value, type: :phrase

include_set Abstract::MetricChild, generation: 2

event :set_metric_value_name,
      before: :set_autoname, when: :invalid_value_name? do
  self.name =
    %w(metric company year).map do |part|
      fetch_name_part part
    end.join "+"
end

event :validate_update_date, :validate,
      on: :update, when: proc { |c| c.year_updated? } do
  new_year = subfield(:year).item_names.first
  new_name = "#{metric_name}+#{company_name}+#{new_year}"
  if new_year != year && Card.exists?(new_name)
    errors.add :year, "value for year #{year} already exists"
    abort :failure
  end
  self.name = new_name
  detach_subfield(:year)
end

def filtered_item_query filter={}, sort={}, paging={}
  filter[:year] = year.to_i
  FixedMetricAnswerQuery.new metric_card.id, filter, sort, paging
end

def valid_value_name?
  cardname.parts.size >= 3 && valid_metric? && valid_company? && valid_year?
end

def invalid_value_name?
  !valid_value_name?
end

def fetch_name_part part
  name_part = name_part_from_name(part) || name_part_from_field(part)
  check_name_part name_part
end

def name_part_from_name part
  return unless send("valid_#{part}?")
  send part
end

def name_part_from_field part
  field = remove_subfield part
  return unless field
  field.content.gsub("[[", "").gsub("]]", "")
end

def check_name_part name
  unless name
    errors.add :name, "missing #{part} part"
    return
  end
  name
end

def valid_metric?
  metric_card && metric_card.type_id == MetricID
end

def valid_company?
  company_card && company_card.type_id == WikirateCompanyID
end

def valid_year?
  year_card && year_card.type_id == YearID
end

def year_updated?
  (year_card = subfield(:year)) && !year_card.item_names.size.zero?
end
