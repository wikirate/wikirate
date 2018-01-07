event :update_answer_lookup_table_due_to_value_change, :finalize, on: :update do
  update_answer answer_id: answer_id
end

event :delete_answer_lookup_table_entry_due_to_value_change, :finalize, on: :delete do
  delete_answer answer_id: answer_id
end

event :create_answer_lookup_entry_due_to_value_change, :finalize, on: :create do
  create_answer answer_id: answer_id
end

def answer_id
  left ? left.id : director.parent.card.id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
end
