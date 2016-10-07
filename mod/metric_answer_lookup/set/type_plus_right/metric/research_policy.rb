event :update_metric_answer_lookup_table_due_to_policy_change, :integrate do
  left.metric_value_cards.each do |metric_answer_card|
    refresh_metric_answer_looup_entry metric_answer_card.id
  end
end
