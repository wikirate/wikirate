@@options = {
  junction_only: true,
  assigns_type: true,
  anchor_parts_count: 2
}

METRIC_TYPE_KEYS = ::Set.new(['researched', 'formula', 'wiki_rating', 'score'])

def label name
  %{All "+#{name.to_name.tag}" cards on metric cards of type "#{name.to_name.left_name}"}
end

def prototype_args anchor
  { name: "+#{anchor.tag}", supercard: Card.new( name: '*dummy', type: Card::MetricID, '+*metric_type'=>"[[#{anchor.trunk}]]" ) }
end

def anchor_name card
  left = card.left
  type_name = (left && left.type_name) || Card[ Card.default_type_id ].name
  "#{type_name}+#{card.cardname.tag}"
end

def follow_label name
  %{all  "+#{name.to_name.tag}" on "#{name.to_name.left_name} metrics"}
end

def pattern_applies? card
  (l = card.cardname.left_name) && METRIC_TYPE_KEYS.include?(l.key)
end
