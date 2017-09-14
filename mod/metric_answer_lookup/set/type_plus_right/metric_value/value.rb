event :update_answer_lookup_table_due_to_value_change, :finalize do
  answer_id = left ? left.id : director.parent.card.id
  # FIXME: director.parent thing fixes case where metric answer is renamed.
  refresh_answer_lookup_entry answer_id
end
