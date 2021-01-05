include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

def record_id
  left_id.positive? ? left_id : super
end

def value_type_code
  metric_card.simple_value_type_code
end

def value_cardtype_code
  metric_card.simple_value_cardtype_code
end
