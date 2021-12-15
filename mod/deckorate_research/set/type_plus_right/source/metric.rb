include_set Abstract::SearchCachedCount
include_set Right::BrowseMetricFilter

def query_hash
  { source: left.id }
end

# recount no. of sources on metric when citation is changed
recount_trigger :type_plus_right, :metric_answer, :source do |citation|
  metric_searches_for_sources citation
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    source_metric_counts_for_citation changed_card.left&.source_card
  end
end

def self.metric_searches_for_sources citation
  citation.changed_item_names.map do |source_name|
    source_name.card.fetch :metric
  end.compact
end
