include_set Abstract::SolidCache, cached_format: :json

# refresh the topic+all companies if source's company changed
ensure_set { TypePlusRight::Source::WikiRateCompany }
cache_expire_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :wikirate_topic
  next unless topics
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_companies)
  end
end

# refresh the topic+all companies if claim's company changed
ensure_set { TypePlusRight::Claim::WikiRateCompany }
cache_expire_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :wikirate_topic
  next unless topics
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_companies)
  end
end

# recount topics associated with a company whenever <source>+topic is edited
ensure_set { TypePlusRight::Source::WikirateTopic }
cache_expire_trigger TypePlusRight::Source::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_companies)
  end
end

# recount topics associated with a company whenever <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
cache_expire_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_companies)
  end
end

# recount topics associated with a company whenever <Metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
cache_expire_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  next unless names
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_companies)
  end
end
# metric value name change, create or delete may expire the cache
cache_expire_trigger Type::MetricValue do |changed_card|
  # FIXME: clean the cache cleverly
  topics = changed_card.metric_card.fetch(trait: :wikirate_topic, new: {})
                       .item_names
  next unless topics
  topics.map do |topic|
    Card.fetch topic.to_name.trait(:all_companies)
  end
end

def update_topic_company_cached_count size
  cc_card = left.fetch(trait: :wikirate_company)
                .fetch(trait: :cached_count, new: {})
  cc_card.update_attributes! content: size
end

# get all related company
def updated_content_for_cache _changed_card=nil
  ids = left.related_companies
  update_topic_company_cached_count ids.size
  related_company_ids_to_json ids
end
