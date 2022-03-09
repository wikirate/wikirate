# answers that cite this source
include_set Abstract::SearchCachedCount
include_set Abstract::FullAnswerSearch
include_set Abstract::Chart

def query_hash
  { source: left_id }
end

# recount answers when a citation is updated
recount_trigger :type_plus_right, :metric_answer, :source do |citation|
  answer_searches_for_sources citation
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    answer_searches_for_sources changed_card.left&.fetch :source
  end
end

def self.answer_searches_for_sources citation
  citation.item_cards.map do |source_card|
    source_card.fetch :metric_answer
  end.compact
end
