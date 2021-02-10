event :create_lookup, :finalize, on: :create do
  lookup_class.create self
end

event :delete_lookup, :finalize, on: :delete do
  lookup_class.delete_for_card id
end
