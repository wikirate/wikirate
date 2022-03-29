card_accessor :metric, type: :search
card_accessor :metric_answer, type: :search

def new_metric
  Card.new type_id: Card::MetricID, "+*metric_type": name
end

def researched?
  new_metric.researched?
end

def calculated?
  new_metric.calculated?
end

format :html do
  view :box_bottom do
    count_badges :metric, :metric_answer
  end

  view :box_middle do
    field_nest :description
  end
end
