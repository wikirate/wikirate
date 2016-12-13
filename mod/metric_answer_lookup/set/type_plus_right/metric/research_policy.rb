event :update_answer_lookup_table_due_to_policy_change, :finalize do
  left.metric_value_cards.each do |answer_card|
    refresh_answer_lookup_entry answer_card.id
  end
end
