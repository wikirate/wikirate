@@options = {
  junction_only: true,
  assigns_type: true,
  index: 4,
  anchor_parts_count: 2
}

def label name
  %(All "#{name.to_name.left}" + "#{name.to_name.right}" cards)
end

def prototype_args _anchor
  {}
end

def anchor_name card
  left = Card.quick_fetch card.cardname.left
  right = Card.quick_fetch card.cardname.right
  ltype_name = left ? left.type_name : "Basic" # hardcode for speed
  rtype_name = right ? right.type_name : "Basic"

  "#{ltype_name}+#{rtype_name}"
end
