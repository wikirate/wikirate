# cache # of metrics with answers for this company (=left)
include_set Abstract::AnswerLookupCachedCount, target_type: :metric

assign_type :record

def query_hash
  { company_id: left_id }
end

# recount metrics related to company whenever a value is created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  changed_card.company_card&.fetch :metric
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    changed_card.left.company_card&.fetch :metric
  end
end
