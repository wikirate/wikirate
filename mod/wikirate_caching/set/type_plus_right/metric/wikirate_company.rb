# cache # of companies with values for metric (=_left)
include_set Abstract::AnswerLookupCachedCount, target_type: :company

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  changed_card.metric_card.fetch(:wikirate_company)
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  return if changed_card.left&.action&.in? %i[create delete]

  changed_card.left.metric_card.fetch(:wikirate_company)
end

def search_anchor
  { metric_id: left.id }
end
