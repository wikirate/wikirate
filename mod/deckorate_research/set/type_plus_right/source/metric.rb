include_set Abstract::CachedCount
include_set Abstract::MetricSearch

def query_hash
  { source: left_id }
end

# recount no. of sources on metric when citation is changed
recount_trigger :type_plus_right, :answer, :source do |citation|
  metric_searches_for_sources citation.changed_item_cards
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  metric_searches_for_sources changed_card.left&.fetch(:source)&.item_cards
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  metric_searches_for_sources changed_card.left&.fetch(:source)&.item_cards
end

def self.metric_searches_for_sources sources
  sources.map { |source_card| source_card.fetch :metric }.compact
end
