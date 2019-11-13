include_set Abstract::MetricChild, generation: 1
include_set Abstract::DesignerPermissions

event :validate_value_type_type_and_content do
  errors.add :type, "must be Pointer" unless type_id == Card::PointerID
  errors.add :content, "must be valid value type" unless valid_content?
end

event :validate_type_of_existing_values, :validate,
      on: :save, changed: :content do
  metric_card.validate_all_values self
end

def valid_content?
  value_type_code.in? %i[number category multi_category money free_text]
end

def value_type
  item_names.first
end

def value_type_code
  item_cards.first&.codename
end
