# answers that cite this source
include_set Abstract::SearchCachedCount

# def search_anchor
#   { answer_id: answer_ids }
# end

def cql_content
  { type_id: MetricAnswerID,
    not: { right_plus: [:unpublished, { eq: "1" }] },
    right_plus: [SourceID, { link_to: name.left }] }
end

# recount answers when a citation is updated
recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  source_answer_for_citation changed_card
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    source_answer_for_citation changed_card.left&.fetch :source
  end
end

def self.source_answer_for_citation citation
  citation.item_cards.map do |source_card|
    source_card.fetch :metric_answer
  end.compact
end
