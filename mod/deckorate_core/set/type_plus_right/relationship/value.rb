include_set Abstract::MetricChild, generation: 4
include_set Abstract::LookupField

def lookup_columns
  %i[value numeric_value route updated_at]
end

event :validate_relationship_value_type, :validate, on: :save do
  errors.add :type, "not a valid +value card" unless type_code.to_s.match?(/value$/)
end

def typed_value?
  true
end

def type_code_from_metric
  metric_card&.value_cardtype_code
end

def relationship_count_value?
  false
end
