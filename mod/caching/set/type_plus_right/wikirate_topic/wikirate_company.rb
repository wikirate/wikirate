# cache # of companies related to this topic (=left) via answers for metrics that
# are tagged with this topic
include_set Abstract::AnswerTableCachedCount, target_type: :company

def search_anchor
  { metric_id: ids_of_metrics_tagged_with_topic }
end

def topic_name
  name.left_name
end

# when metric value is edited
recount_trigger :type, :metric_value do |changed_card|
  next unless (metric_card = changed_card.metric_card)
  company_plus_topic_cards_for_metric metric_card
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  metric_card = changed_card.left
  company_plus_topic_cards_for_metric metric_card
end

def self.company_plus_topic_cards_for_metric metric_card
  topic_pointer = metric_card.fetch trait: :wikirate_topic
  return [] unless topic_pointer
  topic_names =
    Abstract::CachedCount.pointer_card_changed_card_names(topic_pointer)
  topic_names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:wikirate_company)
  end
end

def ids_of_metrics_tagged_with_topic
  Card.search type_id: MetricID,
              right_plus: [WikirateTopicID, { refer_to: name.left }],
              return: :id
end

def company_ids_by_metric_count
  Answer.group(:company_id)
        .where(metric_id: ids_of_metrics_tagged_with_topic)
        .order("count_all desc")
        .limit(100)
        .count
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
        company_card,
        "#{metric_count} #{:metric.name.vary :plural}",
        path: { filter: { wikirate_topic: card.topic_name.s } }
      )
    end
  end
end
