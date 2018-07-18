event :save_overridden_calculated_value, :prepare_to_store,
      on: :create, changed: :content, when: :overridden_value? do
  add_subcard [name.left, :overridden_value], content: left.answer.value, type: :phrase
end

def overridden_value?
  left&.answer&.virtual?
end
