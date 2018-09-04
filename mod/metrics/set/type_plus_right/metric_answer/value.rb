include_set Abstract::MetricChild, generation: 3
# include_set Abstract::Value

def relationship_count_value?
  metric_card.relationship?
end

event :validate_answer_value_type, :validate, on: :save do
  errors.add :type, "not a valid +value card" unless type_code.to_s =~ /value$/
end
