# cache # of metrics with answers for that cite this source
include_set Abstract::AnswerLookupCachedCount, target_type: :metric

def search_anchor
  { answer_id: answer_ids }
end

def answer_ids
  Card.search type_id: MetricAnswerID, return: :id,
              not: { right_plus: [:unpublished, { eq: "1" }] },
              right_plus: [SourceID, { link_to: name.left }]
end

def skip_search?
  answer_ids.blank? || super
end

# recount no. of sources on metric when citation is changed
recount_trigger :type_plus_right, :metric_answer, :source do |citation|
  metric_lists_for_sources citation
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |citation|
  field_recount(citation) { metric_lists_for_sources citation }
end

def self.metric_lists_for_sources citation
  citation.item_cards.map do |source_card|
    source_card.fetch :metric
  end.compact
end
