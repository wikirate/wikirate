include_set Right::BrowseTopicFilter

def filter_keys
  # don't show company filter (already filtering by current company)
  super - [:wikirate_company]
end

def wql_from_content
  { type_id: WikirateTopicID,
    referred_to_by: { left_id: [:in] + metric_ids,
                      right_id: WikirateTopicID },
    append: company_name }
end
