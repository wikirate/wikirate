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
  ltype = left_type card
  rtype = quick_type card.name.right_name
  "#{ltype}+#{rtype}"
end
