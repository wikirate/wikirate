event :update_company_group_lists_based_on_metric, :integrate do
  company_group_lists_for_metric(metric_id).each do |grouplist|
    grouplist.update_content_from_spec
    grouplist.save!
  end
end

def company_group_lists_for_metric metric_id
  Card.search type: :company_group,
              right_plus: [:specification, { refer_to: metric_id }],
              append: :wikirate_company
end
