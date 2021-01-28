event :update_answer_lookup_table_checked_requested_by, :finalize, changed: :content do
  update_answer answer_id: left_id unless left.action == :create
end
