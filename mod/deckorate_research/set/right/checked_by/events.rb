event :add_check, :prepare_to_store, on: :save, trigger: :required do
  add_item user.name
end

event :drop_check, :prepare_to_store, on: :update, trigger: :required do
  drop_item user.name
end
