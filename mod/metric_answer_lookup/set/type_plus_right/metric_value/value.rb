event :update_metric_answer_lookup_table_due_to_value_change, :integrate do
  refresh_metric_answer_looup_entry left.id
end
