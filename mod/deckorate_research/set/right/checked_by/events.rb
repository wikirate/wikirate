# TODO: support unchecking (!) and multiple requests (?)
event :add_check_request, :prepare_to_store,
      on: :save, changed: :content, when: :check_requested? do
  field :check_requested_by, content: user.name unless check_requester.present?
end

event :add_check, :prepare_to_store, on: :save, trigger: :required do
  check_requested? ? (self.content = user.name) : add_item(user.name)
end

event :drop_check, :prepare_to_store, on: :update, trigger: :required do
  drop_item user.name
end
