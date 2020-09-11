def name_part_types
  %w[metric company year]
end

# on creation, we attempt to compose a valid name
event :set_answer_name, before: :set_autoname, when: :invalid_answer_name? do
  self.name = compose_name
end

event :auto_add_company, after: :set_answer_name, on: :create, trigger: :required do
  add_company name_part("company") unless valid_company?
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

event :validate_answer_name, :validate, on: :save, changed: :name do
  validate_name_parts
end

def add_company company
  company_card = Card[company]
  if company_card&.real?
    errors.add "#{company} is not a Company; it's a #{company_card.type_name}"
  else
    Card.create type: WikirateCompanyID, name: company
  end
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
  (metric_card&.type_id == Card::MetricID) || Director.include?(metric)
end

def valid_company?
  return false unless company

  (company_card&.type_id == Card::WikirateCompanyID) || Director.include?(company)
end

def valid_year?
  year_card&.type_id == Card::YearID
end

def compose_name
  Card::Name[name_part_types.map { |type| name_part type }]
end

def name_part type
  name_part_from_field(type) || name_part_from_name(type)
end

def name_part_from_name type
  send type
end

def name_part_from_field type
  field = remove_subfield type
  return unless field&.content.present?
  field.content.gsub("[[", "").gsub("]]", "")
end
