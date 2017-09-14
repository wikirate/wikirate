
@@options = {
  index: 4,
  anchor_parts_count: 1
}

def source_type card_or_name
  source_name = card_or_name.is_a?(Card) ? card_or_name.name : card_or_name
  st_name = "#{source_name}+*source type"
  st_card = Card.fetch(st_name, skip_modules: true, skip_type_lookup: true)
  st_card ||= card_or_name.is_a?(Card) && card_or_name.subfield(:source_type)
  st_type = st_card && st_card.content.scan(/\[\[([^\]]+)\]\]/).flatten.first
  st_type || "Link"
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
