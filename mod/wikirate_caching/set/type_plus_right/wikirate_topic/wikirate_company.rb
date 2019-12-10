# cache # of companies related to this topic (=left) via answers for metrics that
# are tagged with this topic
include_set Abstract::AnswerTableCachedCount, target_type: :company

def search_anchor
  { metric_id: metric_ids }
end

def topic_name
  name.left_name
end

def metric_ids
  left.fetch(trait: :metric, new: {}).item_ids
end

def skip_search?
  metric_ids.empty?
end

# when metric value is edited
recount_trigger :type, :metric_answer do |changed_card|
  next unless (metric_card = changed_card.metric_card)
  topic_company_type_plus_right_cards_for_metric metric_card
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  metric_card = changed_card.left
  topic_company_type_plus_right_cards_for_metric metric_card
end

class << self
  def topic_company_type_plus_right_cards_for_metric metric_card
    topic_names_for_metric(metric_card).map do |topic_name|
      # FIXME: validate topics so this is not a problem (?)
      next unless Card.fetch_type_id(topic_name) == Card::WikirateTopicID
      Card.fetch topic_name, :wikirate_company
    end.compact
  end

  def topic_names_for_metric metric_card
    return unless (topic_pointer = metric_card.fetch trait: :wikirate_topic)
    topic_pointer.changed_item_names
  end
end
