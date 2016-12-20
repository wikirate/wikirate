include Card::CachedCount
include_set Abstract::WqlSearch

def topic_name
  cardname.left_name
end

# when metric value is edited
recount_trigger Type::MetricValue do |changed_card|
  next unless (metric_card = changed_card.metric_card)
  company_plus_topic_cards_for_metric metric_card
end

# ... when <metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  metric_card = changed_card.left
  company_plus_topic_cards_for_metric metric_card
end

def self.company_plus_topic_cards_for_metric metric_card
  topic_pointer = metric_card.fetch trait: :wikirate_topic
  return [] unless topic_pointer
  topic_names =
    Card::CachedCount.pointer_card_changed_card_names(topic_pointer)
  topic_names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:wikirate_company)
  end
end

def search args={}
  # TODO: Support paging
  case args.delete(:return)
  when :id    then company_ids
  when :name  then company_ids.map(&:cardname)
  when :count then count
  else             company_ids.map(&:card)
  end
end

def company_ids
  @company_ids ||= relation.pluck(:company_id)
end

def wql_hash
  if company_ids.any?
    { id: company_ids.unshift(:in) }
  else
    { id: -1 } # HACK: ensure no results
  end
end

def ids_of_metrics_tagged_with_topic
  Card.search type_id: MetricID,
              right_plus: [WikirateTopicID, { refer_to: cardname.left }],
              return: :id
end

def relation
  Answer.select(:company_id)
        .where(metric_id: ids_of_metrics_tagged_with_topic).uniq
end

def company_ids_by_metric_count
  Answer.group(:company_id)
        .where(metric_id: ids_of_metrics_tagged_with_topic)
        .order("count_all desc")
        .limit(100)
        .count
end

def count
  relation.count
end

format :html do
  view :company_list_with_metric_counts do
    wrap do
      card.company_ids_by_metric_count.map do |company_id, metric_count|
        company_card = Card.fetch company_id
        wrap_with :div, class: "company-item contribution-item" do
          [wrap_with(:div, company_detail(company_card), class: "header"),
           wrap_with(:div, class: "data") do
             metric_count_detail(company_card, metric_count)
           end]
        end
      end
    end
  end

  def company_detail company_card
    nest company_card, view: :thumbnail
  end

  def metric_count_detail company_card, metric_count
    wrap_with :span, class: "metric-count-link" do
      link_to_card(
        card.topic_name,
        "#{metric_count} #{:metric.cardname.vary :plural}",
        path: { filter: { wikirate_company: company_card.cardname.url_key } }
      )
    end
  end
end

# include_set Abstract::SolidCache, cached_format: :json
#
# # recount topics associated with a company whenever <Metric>+topic is edited
# ensure_set { TypePlusRight::Metric::WikirateTopic }
# cache_expire_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
#   names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
#   next unless names
#   names.map do |topic_name|
#     Card.fetch topic_name.to_name.trait(:all_companies)
#   end
# end
#
# # metric value name change, create or delete may expire the cache
# cache_expire_trigger Type::MetricValue do |changed_card|
#   # FIXME: clean the cache cleverl
#   topic_list = changed_card.metric_card.fetch trait: :wikirate_topic, new: {}
#   topics = topic_list.item_names
#   next unless topics
#   topics.map do |topic|
#     Card.fetch topic.to_name.trait(:wikirate_company)
#   end
# end

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
