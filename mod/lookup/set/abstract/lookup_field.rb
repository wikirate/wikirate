def lookup_card
  left
end

def lookup
  lookup_card.lookup
end

def lookup_columns
  Codename[right_id]
end

event :update_lookup_field, :finalize, changed: :content do
  return if lookup_card.action.in? %i[create delete]

  lookup.refresh(*Array.wrap(lookup_columns))
end
