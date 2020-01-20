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
  left.fetch(:metric, new: {}).item_ids
end

def skip_search?
  metric_ids.empty?
end

# when metric value is edited
recount_trigger :type, :metric_answer do |changed_card|
  topic_names = changed_card.metric_card&.wikirate_topic_card&.item_names
  company_cache_cards_for_topics topic_names
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  company_cache_cards_for_topics changed_card.changed_item_names
end

class << self
  def company_cache_cards_for_topics topic_names
    topic_names.map do |topic_name|
      # TODO: confirm all +topic items are valid topics so this check isn't necessary
      # (validation is in place)
      next unless Card.fetch_type_id(topic_name) == Card::WikirateTopicID
      Card.fetch topic_name, :wikirate_company
    end.compact
  end
end
