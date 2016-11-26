event :update_metric_answer_lookup_table_due_to_value_change, :finalize do
  refresh_metric_answer_lookup_entry left.id
end
