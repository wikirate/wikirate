include_set Abstract::SearchCachedCount

def company_name
  name.left_name
end

# when metric value is edited
recount_trigger :type, :metric_answer do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  metric_id = changed_card.left_id
  Answer.select(:company_id).where(metric_id: metric_id).distinct
        .pluck(:company_id).map do |company_id|
    Card.fetch(company_id.cardname.trait(:wikirate_topic))
  end
end

def wql_from_content
  { type_id: WikirateTopicID, sort: :name,
    referred_to_by: { left_id: [:in] + metric_ids,
                      right_id: WikirateTopicID } }
end

def skip_search?
  metric_ids.empty?
end

# turn query caching off because wql_hash varies
def cache_query?
  false
end

def metric_ids
  @metric_ids ||=
    ::Answer.select(:metric_id).where(company_id: left.id).distinct.pluck(:metric_id)
  # pluck seems dumb here, but .all isn't working (returns *all card)
end
