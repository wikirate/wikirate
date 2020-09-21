include_set Right::BrowseTopicFilter

def cql_content
  { type_id: Card::WikirateTopicID,
    referred_to_by: { left_id: [:in] + metric_ids,
                      right_id: Card::WikirateTopicID },
    append: company_name }
end

def bookmark_type
  :wikirate_topic
end
