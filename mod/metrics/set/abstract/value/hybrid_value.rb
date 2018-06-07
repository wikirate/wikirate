event :save_overridden_calculated_value, :prepare_to_store,
      on: :create, changed: :content, when: :calculated_value? do
  add_subcard [name.left, :calculated_value], content: left.answer.value, type: :phrase
end

def calculated_value?
  left&.answer&.virtual?
end
