def move name_parts
  without_move_conflict name_parts do |move_attrib|
    update move_attrib
  end
end

def move! name_parts
  update! move_attributes(move_name(name_parts))
end

def move_attributes name
  { name: name, silent_change: true }
end

def without_move_conflict name_parts
  new_name = move_name name_parts
  return if Card.exist? new_name

  yield move_attributes(new_name)
end

def move_name name_parts
  cleaned_parts = name_part_types.map do |key|
    (name_parts[key.to_sym] || send(key).to_s).cardname
  end
  Card::Name[*cleaned_parts]
end
