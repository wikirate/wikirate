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
  lookup_field_update do
    lookup.refresh(*Array.wrap(lookup_columns))
  end
end

private

def lookup_field_update
  yield unless lookup_card.action.in? %i[create delete]
end
