# cache # of metrics with answer for this company (=left)
include_set Abstract::AnswerLookupCachedCount, target_type: :metric

assign_type :record

def query_hash
  { company_id: left_id }
end

# recount metrics related to company whenever a value is created or deleted
recount_trigger :type, :answer, on: %i[create delete] do |changed_card|
  changed_card.company_card&.fetch :metric
end

# # ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  changed_card.left.fetch(:company).answer_query
              .pluck(:company_id).map do |company_id|
    company_id.card.fetch :metric
  end
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
  changed_card.left.company_card&.fetch :metric
end
