include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions

event :validate_value_type_type_and_content do
  errors.add :type, "must be Pointer" unless type_id == Card::PointerID
  errors.add :content, "must be valid value type" unless valid_content?
end

event :validate_value_type_matches_values, :validate, on: :save, changed: :content do
  return unless (error_message = metric_card.validate_all_values)

  errors.add :answers, "Cannot change to #{content}: #{error_message}"
end

def valid_content?
  first_code.in? %i[number category multi_category money free_text]
end

def value_type
  first_name
end
