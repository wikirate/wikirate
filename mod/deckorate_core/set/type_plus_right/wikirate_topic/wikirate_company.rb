include_set Right::BrowseCompanyFilter

# cache # of companies related to this topic (=left) via answers for metrics that
# are tagged with this topic
include_set Abstract::AnswerLookupCachedCount, target_type: :company

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

# when answer is created/deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  company_cache_cards_for_answer changed_card
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    company_cache_cards_for_answer changed_card.left
  end
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  company_cache_cards_for_topics changed_card.changed_item_names
end

class << self
  def company_cache_cards_for_answer answer
    company_cache_cards_for_topics topic_names_for_answer(answer)
  end

  def topic_names_for_answer answer
    answer.metric_card&.wikirate_topic_card&.item_names
  end

  def company_cache_cards_for_topics topic_names
    topic_names.map do |topic_name|
      # TODO: confirm all +topic items are valid topics so this check isn't necessary
      # (validation is in place)
      next unless Card.fetch_type_id(topic_name) == WikirateTopicID
      Card.fetch topic_name, :wikirate_company
    end.compact
  end
end
