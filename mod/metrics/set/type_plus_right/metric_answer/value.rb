include_set Abstract::MetricChild, generation: 3
include_set Abstract::Value

def relationship_count_value?
  metric_card.relationship?
end
