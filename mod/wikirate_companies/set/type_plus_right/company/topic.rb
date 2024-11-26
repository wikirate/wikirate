# order of the following two matters for filtering, but I don't really know why
# include_set Abstract::SearchCachedCount
include_set Abstract::TopicSearch

# # recount num of topics for a given company when answer is created/deleted
# recount_trigger :type, :answer, on: %i[create delete] do |changed_card|
#   changed_card.company_card&.fetch :topic
# end
#
# # ...or when metric is (un)published
# field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
#   changed_card.left.fetch :topic
# end
#
# # ...or when answer is (un)published
# field_recount_trigger :type_plus_right, :answer, :unpublished do |changed_card|
#   changed_card.left.company_card&.fetch :topic
# end
#
# # ... when <metric>+topic is edited
# recount_trigger :type_plus_right, :metric, :topic do |changed_card|
#   metric = changed_card.left
#   metric.fetch(:company).answer_query.pluck(:company_id).map do |company_id|
#     company_id.card&.fetch :topic
#   end
# end

def company_name
  name.left_name
end

def bookmark_type
  :topic
end

def cql_content
  { type: :topic,
    referred_to_by: { left_id: answer_relation, right: :topic },
    append: company_name }
end

def answer_relation
  AnswerQuery.new(company_id: left_id).lookup_relation.select(:metric_id).distinct
end
