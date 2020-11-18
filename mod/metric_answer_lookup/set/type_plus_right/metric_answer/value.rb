event :update_answer_lookup_table_due_to_value_change, :finalize, on: :update do
  update_answer answer_id: answer_id
end

event :delete_answer_lookup_table_entry_due_to_value_change, :finalize, on: :delete do
  return if metric_card&.calculated? # FIXME: AND metric has a valid virtual answer
  delete_answer answer_id: answer_id
end

event :create_answer_lookup_entry_due_to_value_change, :finalize, on: :create do
  if hybrid? && (lookup_id = left&.answer&.id)
    update_answer id: lookup_id
  else
    create_answer answer_id: answer_id
  end
end

def answer_id
  left&.id || director.parent.card.id || left_id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
end
