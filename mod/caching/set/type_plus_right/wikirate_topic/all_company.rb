include Card::CachedCount

# refresh the topic+all company if source's company changed
ensure_set { TypePlusRight::Source::WikiRateCompany }
recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :wikirate_topic
  next unless topics
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

# refresh the topic+all company if claim's company changed
ensure_set { TypePlusRight::Claim::WikiRateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :wikirate_topic
  next unless topics
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <source>+topic is edited
ensure_set { TypePlusRight::Source::WikirateTopic }
recount_trigger TypePlusRight::Source::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
recount_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <Metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end
# metric value name change, create or delete may expire the cache
recount_trigger Type::MetricValue do |changed_card|
  # FIXME: clean the cache cleverly
  topics = changed_card.metric_card.fetch(trait: :wikirate_topic).item_names
  next unless topics
  topics.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

def update_topic_company_cached_count size
  cc_card = left.fetch(trait: :wikirate_company)
                .fetch(trait: :cached_count, new: {})
  cc_card.content = size
  cc_card.save!
end

# get all related company
def calculate_count _changed_card=nil
  ids = left.related_companies
  update_topic_company_cached_count ids.size
  result = {}
  ids.each do |company_id|
    result[company_id] = true unless result.key?(company_id)
  end
  result.to_json
end
