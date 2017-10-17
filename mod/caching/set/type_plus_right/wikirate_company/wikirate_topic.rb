include_set Abstract::SearchCachedCount

def company_name
  name.left_name
end

# when metric value is edited
recount_trigger :type, :metric_value do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:wikirate_topic)
  end
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  metric_id = changed_card.left_id
  Answer.select(:company_id).where(metric_id: metric_id).uniq
        .pluck(:company_id).map do |company_id|
    # faster way to get this from company+topic?
    Card.fetch company_id.cardname.trait(:wikirate_topic)
  end
end

def wql_hash
  metric_ids = unique_metric_ids
  if metric_ids.any?
    {
      type_id: WikirateTopicID,
      referred_to_by: { left_id: [:in] + metric_ids,
                        right_id: WikirateTopicID }
    }
  else
    { id: -1 } # HACK: ensure no results
  end
end

# turn query caching off because wql_hash varies and fetch_query doesn't recognizes
# changes in wql_hash
def fetch_query args={}
  query(args.clone)
end

# faster way to get this from company+metric?
def unique_metric_ids
  Answer.select(:metric_id).where(company_id: left.id).uniq.pluck :metric_id
  # pluck seems dumb here, but .all isn't working (returns *all card)
end

def topics_by_metric_count
  topic_count_hash =
    item_cards(limit: 0).each_with_object({}) do |topic_card, count_hash|
      count_hash[topic_card] = topic_card.metric_card.cached_count
      count_hash
    end
  topic_count_hash.sort_by { |_card, count| count }.reverse
end

format :html do
  view :topic_list_with_metric_counts do
    wrap do
      card.topics_by_metric_count.map do |topic_card, metric_count|
        wrap_with :div, class: "topic-item contribution-item" do
          [wrap_with(:div, topic_detail(topic_card), class: "header"),
           wrap_with(:div, class: "data") do
             metric_count_detail(topic_card, metric_count)
           end]
        end
      end
    end
  end

  def topic_detail topic_card
    nest topic_card, view: :thumbnail
  end

  def metric_count_detail topic_card, metric_count
    wrap_with :span, class: "metric-count-link" do
      link_to_card(
        card.company_name,
        "#{metric_count} #{:metric.name.vary :plural}",
        path: { filter: { wikirate_topic: topic_card.name } }
      )
    end
  end
end
