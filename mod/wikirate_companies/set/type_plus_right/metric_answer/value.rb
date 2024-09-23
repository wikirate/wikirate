event :update_company_group_lists_based_on_metric,
      :integrate_with_delay, priority: 15 do
  metric_card.company_group_lists.each do |grouplist|
    next if grouplist.cached_count > 10_000
    grouplist.update_content_from_spec
    grouplist.save!
  end
end
