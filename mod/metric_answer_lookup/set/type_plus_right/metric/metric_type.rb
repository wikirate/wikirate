event :update_metric_answer_lookup_table_due_to_metric_type_change, :finalize do
  left.metric_value_cards.each do |metric_answer_card|
    refresh_metric_answer_lookup_entry metric_answer_card.id
  end
end
