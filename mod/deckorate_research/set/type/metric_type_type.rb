card_accessor :metric, type: :search_type
card_accessor :answer, type: :search_type

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
  view :core do
    [field_nest(:description),
     field_nest(:metric, view: :titled, title: "Metrics")]
  end

  view :box_bottom do
    count_badges :metric, :answer
  end

  view :box_middle do
    field_nest :description
  end
end
