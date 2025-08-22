# this is a bit of a hack.
# Since we don't add renamed children to the act any more, we
# have to trigger the value validation manually
event :run_value_events_on_name_change, :validate, changed: :name, on: :update do
  value_card = Card[name_before_act, :value]
  value_card.instance_variable_set "@name", Card::Name[name, :value]
  value_card.valid?
  value_card.errors.each do |error|
    errors.add :value, error.message
  end
end

# on creation, we attempt to compose a valid name
event :set_answer_name, :prepare_to_validate, on: :save, when: :compose_name? do
  self.name = compose_name
end

event :auto_add_company, after: :set_answer_name, on: :create, trigger: :required do
  add_company name_part("company") unless valid_company?
end

event :validate_answer_name, :validate, on: :save, changed: :name do
  validate_name_parts
end

def compose_name?
  name_part_types.any? { |part| subfield? part }
end

private

def name_part_types
  %w[metric company year]
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
  part = drop_field(type)&.content
  part if part.present?
end

def add_company company
  company_card = Card[company]
  if company_card&.real?
    errors.add "#{company} is not a Company; it's a #{company_card.type_name}"
  else
    Card.create type: CompanyID, name: company
  end
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

  (company_card&.type_id == Card::CompanyID) || Director.include?(company)
end

def valid_year?
  year_card&.type_id == Card::YearID
end
