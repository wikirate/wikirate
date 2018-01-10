event :update_answer_lookup_table_due_to_metric_type_change, :finalize, on: :update do
  update_answer metric_id: left_id
end
