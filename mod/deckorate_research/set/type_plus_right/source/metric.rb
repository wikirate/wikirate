include_set Abstract::CachedCount
include_set Abstract::MetricSearch

def query_hash
  { source: left_id }
end

# recount no. of sources on metric when citation is changed
recount_trigger :type_plus_right, :metric_answer, :source do |citation|
  metric_searches_for_sources citation
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    metric_searches_for_sources changed_card.left&.source_card
  end
end

def self.metric_searches_for_sources citation
  citation.changed_item_cards.map do |source_card|
    source_card.fetch :metric
  end.compact
end
