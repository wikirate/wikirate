include Card::CachedCount

# refresh the topic+all company if source's company changed
ensure_set { TypePlusRight::Source::WikiRateCompany }
recount_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :WikirateTopic
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

# refresh the topic+all company if claim's company changed
ensure_set { TypePlusRight::Claim::WikiRateCompany }
recount_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
  topics = changed_card.left.fetch trait: :WikirateTopic
  topics.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <source>+topic is edited
ensure_set { TypePlusRight::Source::WikirateTopic }
recount_trigger TypePlusRight::Source::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
recount_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end

# recount topics associated with a company whenever <Metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:all_company)
  end
end
# metric value name change, create or delete may expire the cache
recount_trigger Type::MetricValue do |changed_card|
  # FIXME: clean the cache cleverly
  topics = changed_card.metric_card.fetch(trait: :wikirate_topic).item_names
  topics.map do |topic|
    Card.fetch topic.to_name.trait(:all_company)
  end
end

def related_company_from_source_or_note
  Card.search(type_id: Card::WikirateCompanyID,
              referred_to_by: {
                left: {
                  type: %w(in Note Source),
                  right_plus: ["topic", refer_to: cardname.left]
                },
                right: "company"
              },
              return: "id")
end

def related_company_from_metric
  Card.search type_id: Card::WikirateCompanyID,
              left_plus: [
                {
                  type_id: Card::MetricID,
                  right_plus: ["topic", { refer_to: cardname.left }]
                },
                {
                  right_plus: ["*cached_count", { content: %w(ne 0) }]
                }
              ],
              return: :id
end

# get all related company
def calculate_count _changed_card=nil
  ids = (related_company_from_source_or_note + related_company_from_metric).uniq
  result = {}
  ids.each do |company_id|
    result[company_id] = true unless result.key?(company_id)
  end
  result.to_json
end
