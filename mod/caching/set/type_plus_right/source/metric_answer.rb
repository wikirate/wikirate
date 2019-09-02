# answers that cite this source
include_set Abstract::SearchCachedCount

def search_anchor
  { answer_id: answer_ids }
end

def wql_content
  { type_id: MetricAnswerID,
    right_plus: [{ id: Card::SourceID }, { link_to: name.left }] }
end

recount_trigger :type_plus_right, :metric_answer, :source do |changed_card|
  changed_card.item_cards.map do |source_card|
    source_card.fetch trait: :metric_answer
  end.compact
end
