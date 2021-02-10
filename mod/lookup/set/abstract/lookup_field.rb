def lookup_card
  left
end

def lookup
  lookup_card.lookup
end

def lookup_columns
  [Codename[right_id]]
end

event :update_lookup_field, :finalize, changed: :content do
  lookup.refresh *lookup_columns unless lookup_card.action == :create
end
