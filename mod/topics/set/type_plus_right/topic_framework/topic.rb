include_set Abstract::TopicSearch

def cql_content
  { type: :topic,
    rrigh: { left_id: answer_relation, right: :topic },
    append: company_name }
end