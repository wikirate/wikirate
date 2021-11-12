DEFAULT_METRIC_TYPE = "Researched".freeze

@@options = {
  junction_only: true,
  index: 3,
  anchor_parts_count: 1
}

def metric_type card_or_name
  current_card, metric_name = current_card_and_name card_or_name
  metric_type_name = "#{metric_name}+*metric type"
  metric_type_card =
    metric_type_card_from_fetch(metric_type_name) ||
    metric_type_card_from_subfield(current_card) ||
    metric_type_card_from_act(metric_type_name)

  v = type_from_card_content(metric_type_card) || DEFAULT_METRIC_TYPE
  # puts "metric_name: #{metric_name}; v = #{v}".red
  # binding.pry if metric_name == "Jedi+more evil" && v != "Relationship"
  v
end

def current_card_and_name card_or_name
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

def metric_type_card_from_subfield card
  # puts "subcards for #{card.name}: #{card.subcards.keys}".yellow
  card.subfield :metric_type
end

def type_from_card_content metric_type_card
  metric_type_card&.standard_content&.scan(/^(?:\[\[)?([^\]]+)(?:\]\])?$/)&.flatten&.first
end

def label _name
  "metric type"
end

def pattern_applies? card
  card.type_id == Card::MetricID
end

def prototype_args anchor
  metric_type = metric_type anchor
  { type: "metric", "+*metric_type" => "[[#{metric_type}]]"  }
end

def anchor_name card
  metric_type card
end

def follow_label name
  %(all #{metric_type name} metrics)
end
