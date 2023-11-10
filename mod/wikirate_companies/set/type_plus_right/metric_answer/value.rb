event :update_company_group_lists_based_on_metric,
      :integrate_with_delay, priority: 15 do
  metric_card.company_group_lists.each do |grouplist|
    grouplist.update_content_from_spec
    grouplist.save! unless grouplist.count > 10_000
  end
end
