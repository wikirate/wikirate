event :update_answer_lookup_table_due_to_policy_change, :finalize, changed: :content do
  update_answer metric_id: left_id unless left.new?
  # not sure this `left.new?` test works...
  # idea is that we don't need to run a separate update if the metric itself has just
  # been created.
end
