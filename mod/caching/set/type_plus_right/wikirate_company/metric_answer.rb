# cache # of answers for company
include_set Abstract::AnswerTableCachedCount, target_type: :answer

def search_anchor
  { company_id: left.id }
end

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  changed_card.company_card.fetch trait: :metric_answer
end
