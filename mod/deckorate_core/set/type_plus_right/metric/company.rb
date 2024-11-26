# cache # of companies with values for metric (=_left)
include_set Abstract::AnswerLookupCachedCount, target_type: :company

def query_hash
  { metric_id: left_id }
end

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger :type, :answer, on: %i[create delete] do |changed_card|
  changed_card.metric_card.fetch :company
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  changed_card.left.fetch :company
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  changed_card.left.metric_card.fetch :company
end
