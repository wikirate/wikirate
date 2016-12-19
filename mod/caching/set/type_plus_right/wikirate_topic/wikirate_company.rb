def search args={}
  return_type = args.delete :return
  q = query(args)
  case return_type
  when :name then
    q.run.map(&:name)
  when :count then
    q.count
  else
    q.run
  end
end

def query
  metric_ids = Card.search right_plus: [Card::WikirateTopicID,
                                        { refer_to: cardname.left }],
                           return: :id
  Answer.select(:company_id).where(metric_id: metric_ids).uniq
end

def count
  relation.count
end

# returns array of ids
def all
  relation.all
end

#include_set Abstract::SolidCache, cached_format: :json
#
## recount topics associated with a company whenever <Metric>+topic is edited
#ensure_set { TypePlusRight::Metric::WikirateTopic }
#cache_expire_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
#  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#  next unless names
#  names.map do |topic_name|
#    Card.fetch topic_name.to_name.trait(:all_companies)
#  end
#end
#
## metric value name change, create or delete may expire the cache
#cache_expire_trigger Type::MetricValue do |changed_card|
#  # FIXME: clean the cache cleverl
#  topic_list = changed_card.metric_card.fetch trait: :wikirate_topic, new: {}
#  topics = topic_list.item_names
#  next unless topics
#  topics.map do |topic|
#    Card.fetch topic.to_name.trait(:wikirate_company)
#  end
#end

# # refresh the topic+all companies if source's company changed
# ensure_set { TypePlusRight::Source::WikiRateCompany }
# cache_expire_trigger TypePlusRight::Source::WikirateCompany do |changed_card|
#   topics = changed_card.left.fetch trait: :wikirate_topic
#   next unless topics
#   topics.item_names.map do |topic|
#     Card.fetch topic.to_name.trait(:all_companies)
#   end
# end
#
# # refresh the topic+all companies if claim's company changed
# ensure_set { TypePlusRight::Claim::WikiRateCompany }
# cache_expire_trigger TypePlusRight::Claim::WikirateCompany do |changed_card|
#   topics = changed_card.left.fetch trait: :wikirate_topic
#   next unless topics
#   topics.item_names.map do |topic|
#     Card.fetch topic.to_name.trait(:all_companies)
#   end
# end
#
# # recount topics associated with a company whenever <source>+topic is edited
# ensure_set { TypePlusRight::Source::WikirateTopic }
# cache_expire_trigger TypePlusRight::Source::WikirateTopic do |changed_card|
#   names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#   next unless names
#   names.map do |topic_name|
#     Card.fetch topic_name.to_name.trait(:all_companies)
#   end
# end
#
# # recount topics associated with a company whenever <note>+topic is edited
# ensure_set { TypePlusRight::Claim::WikirateTopic }
# cache_expire_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
#   names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#   next unless names
#   names.map do |topic_name|
#     Card.fetch topic_name.to_name.trait(:all_companies)
#   end
# end
