event :update_company_group_lists_based_on_metric,
      :integrate_with_delay, priority: 15 do
  company_group_lists_for_metric(metric_id).each do |grouplist|
    grouplist.update_content_from_spec
    grouplist.save! unless grouplist.count > 10_000
  end
end

def company_group_lists_for_metric metric_id
  Card.search type: :company_group,
              right_plus: [:specification, { refer_to: metric_id }],
              append: :wikirate_company
end
