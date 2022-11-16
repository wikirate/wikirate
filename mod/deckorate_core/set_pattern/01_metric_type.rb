DEFAULT_METRIC_TYPE = "Researched".freeze

@@options = {
  compound_only: true,
  index: 3,
  anchor_parts_count: 1
}

def label _name
  "metric type"
end

def pattern_applies? card
  card.type_id == Card::MetricID
rescue NameError
  # eg when seeding and metric card doesn't exist yet.
  false
end

def prototype_args anchor
  metric_type = metric_type anchor
  { type: "metric", "+*metric_type" => metric_type  }
end

def anchor_name card
  metric_type card
end

def follow_label name
  %(all #{metric_type name} metrics)
end

private

def metric_type metric_card_or_name
  metric_type_card(metric_card_or_name)&.db_content&.strip || DEFAULT_METRIC_TYPE
end

def metric_type_card metric_card_or_name
  metric_card, metric_name = metric_card_and_name metric_card_or_name
  metric_type_name = "#{metric_name}+*metric type"
  metric_type_card_from_fetch(metric_type_name) ||
    metric_type_card_from_field(metric_card) ||
    metric_type_card_from_act(metric_type_name)
end

def metric_card_and_name card_or_name
  if card_or_name.is_a? Card
    [card_or_name, card_or_name.name]
  else
    [nil, card_or_name]
  end
end

def metric_type_card_from_act metric_type_name
  Card::Director.card metric_type_name
end

def metric_type_card_from_fetch metric_type_name
  Card.fetch metric_type_name, skip_modules: true, skip_type_lookup: true
end

def metric_type_card_from_field metric_card
  # puts "subcards for #{card.name}: #{card.subcards.keys}".yellow
  metric_card.field :metric_type if metric_card.subcards.field(:metric_type).present?
end
