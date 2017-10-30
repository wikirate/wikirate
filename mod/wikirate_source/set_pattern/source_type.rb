
@@options = {
  index: 4,
  anchor_parts_count: 1
}

def source_type card_or_name
  return unless (source_type_card = source_type_from_card(card_or_name) || source_type_from_subfield(card_or_name))
  source_type_card.standard_content.scan(/\[\[([^\]]+)\]\]/).flatten.first || "File"
end

def source_type_from_card card_or_name
  source_name = card_or_name.is_a?(Card) ? card_or_name.name : card_or_name.to_name
  Card.fetch source_name.trait(:source_type), skip_modules: true, skip_type_lookup: true
end

def source_type_from_subfield card_or_name
  return unless card_or_name.is_a? Card
  card_or_name.subfield :source_type
end

def label _name
  "source type"
end

def pattern_applies? card
  card.type_id == Card::SourceID
end

def prototype_args anchor
  source_type = source_type anchor
  { type: :source, "+*source_type" => "[[#{source_type}]]"  }
end

def anchor_name card
  source_type card
end

def follow_label name
  %(all #{source_type name} sources)
end
