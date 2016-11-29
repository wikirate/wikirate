event :update_metric_answer_lookup_table_due_to_value_change, :finalize do
  metric_answer_id = left ? left.id : director.parent.card.id
  # hack? director.parent thing fixes case where metric answer is renamed.
  refresh_metric_answer_lookup_entry metric_answer_id
end
