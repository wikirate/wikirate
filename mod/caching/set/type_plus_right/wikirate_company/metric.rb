# cache # of metrics with answers for this company (=left)
include_set Abstract::AnswerTableCachedCount, target_type: :metric

def search_anchor
  { company_id: left.id }
end

# recount metrics related to company whenever a value is created or deleted
recount_trigger :type, :metric_answer, on: [:create, :delete] do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:metric)
  end
end
