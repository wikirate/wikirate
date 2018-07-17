event :update_answer_lookup_table_due_to_policy_change, :finalize do
  update_answer metric_id: left_id
end
