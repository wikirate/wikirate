def move name_parts
  without_move_conflict name_parts do |move_attrib|
    update move_attrib
  end
end

def move! name_parts
  update! move_attributes(move_name(name_parts))
end

def move_attributes name
  { name: name, update_referers: true, silent_change: true }
end

def without_move_conflict name_parts
  new_name = move_name name_parts
  return if Card.exists? new_name

  yield move_attributes(new_name)
end

def move_name name_parts
  cleaned_parts = %i[metric company year].map do |key|
    Card.fetch_name(name_parts[key] || send(key).to_s)
  end
  Card::Name[*cleaned_parts]
end
