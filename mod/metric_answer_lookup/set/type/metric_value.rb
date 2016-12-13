event :update_answer_lookup_table_due_to_answer_change, :finalize do
  refresh_answer_lookup_entry id
end
