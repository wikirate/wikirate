DEFAULT_METRIC_TYPE = "Researched".freeze

@@options = {
  junction_only: true,
  index: 3,
  anchor_parts_count: 1
}

def metric_type card_or_name
  metric_name = card_or_name.is_a?(Card) ? card_or_name.name : card_or_name
  mt_name = "#{metric_name}+*metric type"
  mt_card = Card.fetch(mt_name, skip_modules: true, skip_type_lookup: true)
  mt_card ||= card_or_name.is_a?(Card) && card_or_name.subfield(:metric_type)
  mt_type =
    mt_card&.standard_content&.scan(/^(?:\[\[)?([^\]]+)(?:\]\])?$/)&.flatten&.first
  mt_type || DEFAULT_METRIC_TYPE
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
