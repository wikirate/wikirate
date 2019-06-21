include_set Right::BrowseTopicFilter

def wql_content
  { type_id: WikirateTopicID,
    referred_to_by: { left_id: [:in] + metric_ids,
                      right_id: WikirateTopicID },
    append: company_name }
end
