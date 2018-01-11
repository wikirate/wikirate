event :update_answer_lookup_table_due_to_answer_change, :finalize, on: :update do
  update_answer answer_id: id
end
