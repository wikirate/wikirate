def new_metric
  Card.new type_id: Card::MetricID, "+*metric_type": name
end

def researched?
  new_metric.researched?
end

def calculated?
  new_metric.calculated?
end