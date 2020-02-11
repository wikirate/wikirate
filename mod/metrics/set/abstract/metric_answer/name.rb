def name_part_types
  %w[metric company year]
end

# on creation, we attempt to compose a valid name
event :set_answer_name, before: :set_autoname, when: :invalid_answer_name? do
  self.name = compose_name
  validate_name_parts
  abort :failure if errors.any?
end

event :validate_year_change, :validate, on: :update, when: :year_updated? do
  new_year = subfield(:year).first_name
  new_name = "#{metric_name}+#{company_name}+#{new_year}"
  if new_year != year && Card.exists?(new_name)
    errors.add :year, "value for year #{new_year} already exists"
    abort :failure
  end
  self.name = new_name
  detach_subfield(:year)
  success.year = new_year if success.year
end

def year_updated?
  (year_card = subfield(:year)) && !year_card.item_names.size.zero?
end

event :validate_answer_name, after: :validate_year_change, on: :save, changed: :name do
  validate_name_parts
end

def invalid_answer_name?
  !valid_answer_name?
end

def valid_answer_name?
  name.parts.size >= (name_part_types.size + 1) && valid_name_parts?
end

def valid_name_parts?
  name_part_types.all? { |type| send "valid_#{type}?" }
end

# TODO: confirm that there are no _extra_ parts
def validate_name_parts
  name_part_types.each do |type|
    next if send "valid_#{type}?"
    errors.add type, "valid #{type} required"
  end
end

def valid_metric?
  # TODO: need better way to check if metric is part of the same act
  #       this doesn't check the type
  (metric_card&.type_id == Card::MetricID) || ActManager.include?(metric)
end

def valid_company?
  (company_card&.type_id == Card::WikirateCompanyID) || ActManager.include?(company)
end

def valid_year?
  year_card&.type_id == Card::YearID
end

def compose_name
  name_part_types.map do |type|
    name_part_from_field(type) || name_part_from_name(type)
  end.join "+"
end

def name_part_from_name type
  return unless send("valid_#{type}?")
  send type
end

def name_part_from_field type
  field = remove_subfield type
  return unless field&.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end
