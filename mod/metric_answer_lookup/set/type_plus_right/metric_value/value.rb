event :update_answer_lookup_table_due_to_value_change, :finalize do
  answer_id = left ? left.id : director.parent.card.id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
  refresh_answer_lookup_entry answer_id
end

event :mark_as_imported, before: :finalize_action do
  return unless ActManager.act_card.type_id == MetricValueImportFileID
  @current_action.comment = "imported"
end
