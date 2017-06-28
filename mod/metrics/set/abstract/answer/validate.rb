event :validate_answer_field, before: :set_answer_name, when: :standard? do
  missing_part :answer unless subfield_present?(:value)
end

event :validate_value_type, :validate, on: :save, when: :standard? do
  # check if the value fit the value type of metric
  if metric_card && metric_card.researched? &&
    (value_type = metric_card.fetch(trait: :value_type)) &&
     (value_card = subfield(:value))
    value = value_card.value
    return if value.casecmp("unknown").zero?
    case value_type.item_names[0]
    when "Number", "Money"
      unless number?(value)
        errors.add :value, "Only numeric content is valid for this metric."
      end
    when "Category"
      # check if the value exist in options
      if !(option_card = Card["#{metric_card.name}+value options"]) ||
         !option_card.item_names.include?(value)
        url = "/#{option_card.cardname.url_key}?view=edit"
        anchor = %(<a href='#{url}' target="_blank">add that option</a>)
        errors.add :value, "#{value} is not a valid option. "\
                           "Please #{anchor} before adding this metric value."
      end
    end
  end
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

event :validate_answer_name,
      after: :validate_update_date, on: :save, changed: :name do
  if Card.fetch_type_id(card.year) != YearID
    errors.add :name, "right part must be a year"
  end
  if cardname.length < 4
    errors.add :name, "must have at least a metric, a company, and a year part"
  end
end

def valid_value_name?
  cardname.parts.size >= (name_parts.size + 1) && valid_name_parts?
end

def invalid_value_name?
  !valid_value_name?
end

def valid_name_parts?
  name_parts.all? { |part| send "valid_#{part}?" }
end

def validate_name_parts
  name_parts.each do |part|
    next if send "valid_#{part}?"
    errors.add part, "#{send part} is not a valid #{part}"
  end
end

def check_name_part part, name
  unless name
    missing_part part
    return
  end
  name
end

def missing_part part
  errors.add part, "no #{part} given."
end

def valid_metric?
  # TODO: need better way to check if metric is part of the same act
  #       this doesn't check the type
  (metric_card && metric_card.type_id == MetricID) ||
    ActManager.include?(metric)
end

def valid_company?
  (company_card && company_card.type_id == WikirateCompanyID) ||
    ActManager.include?(company)
end

def valid_year?
  year_card && year_card.type_id == YearID
end

def year_updated?
  (year_card = subfield(:year)) && !year_card.item_names.size.zero?
end

def number? str
  true if Float(str)
rescue
  false
end
