event :validate_answer_field, before: :set_answer_name, when: :standard? do
  missing_part :answer unless subfield_present?(:value)
end

# TODO: build this or (better yet) standard mechanism for this
# event :validate_presence_of_value, :validate, on: :save do
# end

event :validate_year_change, :validate, on: :update, when: :year_updated? do
  new_year = subfield(:year).item_names.first
  new_name = "#{metric_name}+#{company_name}+#{new_year}"
  if new_year != year && Card.exists?(new_name)
    errors.add :year, "value for year #{new_year} already exists"
    abort :failure
  end
  self.name = new_name
  detach_subfield(:year)
  success.year = new_year if success.year
end

event :validate_answer_name, after: :validate_year_change, on: :save, changed: :name do
  errors.add :name, "right part must be a year" if Card.fetch_type_id(year) != YearID
  if name.length < 4
    errors.add :name, "must have at least a metric, a company, and a year part"
  end
end

event :restore_overridden_value, :validate, on: :delete, when: :calculation_overridden? do
  overridden_value_card.update! content: nil
  answer.restore_overridden_value
end

def valid_answer_name?
  name.parts.size >= (name_part_types.size + 1) && valid_name_parts?
end

def invalid_answer_name?
  !valid_answer_name?
end

def valid_name_parts?
  name_part_types.all? { |type| send "valid_#{type}?" }
end

def validate_name_parts
  name_part_types.each do |type|
    next if send "valid_#{type}?"
    errors.add part, "#{send type} is not a valid #{type}"
  end
end

def check_name_part type, name
  unless name
    missing_part type
    return
  end
  name
end

def missing_part type
  errors.add type, "no #{type} given."
end

def valid_metric?
  # TODO: need better way to check if metric is part of the same act
  #       this doesn't check the type
  (metric_card&.type_id == MetricID) ||
    ActManager.include?(metric)
end

def valid_company?
  (company_card&.type_id == WikirateCompanyID) ||
    ActManager.include?(company)
end

def valid_year?
  year_card&.type_id == YearID
end

def year_updated?
  (year_card = subfield(:year)) && !year_card.item_names.size.zero?
end

def number? str
  true if Float(str)
rescue StandardError
  false
end
