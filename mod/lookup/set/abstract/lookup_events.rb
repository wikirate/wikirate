event :create_lookup, :finalize, on: :create do
  lookup_class.create self
end

event :refresh_lookup, :finalize, changed: :name, on: :update do
  lookup.refresh
end

event :delete_lookup, :finalize, on: :delete do
  lookup_class.delete_for_card id
end
