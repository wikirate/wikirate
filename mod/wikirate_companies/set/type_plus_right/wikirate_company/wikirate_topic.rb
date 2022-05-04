# order of the following two matters for filtering, but I don't really know why
include_set Abstract::SearchCachedCount
include_set Abstract::TopicSearch

# when metric value is edited
recount_trigger :type, :metric_answer, on: %i[create delete] do |changed_card|
  changed_card.company_card&.fetch :wikirate_topic
end

# ...or when answer is (un)published
recount_trigger :type_plus_right, :metric_answer, :unpublished do |changed_card|
  field_recount changed_card do
    changed_card.left.company_card&.fetch :wikirate_topic
  end
end

# ... when <metric>+topic is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |changed_card|
  metric = changed_card.left
  metric.fetch(:wikirate_company).answer_query.pluck(:company_id).map do |company_id|
    company_id.card&.fetch :wikirate_topic
  end
end

def company_name
  name.left_name
end

def bookmark_type
  :wikirate_topic
end

def cql_content
  { type: :wikirate_topic,
    referred_to_by: { left_id: answer_relation, right: :wikirate_topic },
    append: company_name }
end

def answer_relation
  AnswerQuery.new(company_id: left_id).lookup_relation.select(:metric_id).distinct
end
