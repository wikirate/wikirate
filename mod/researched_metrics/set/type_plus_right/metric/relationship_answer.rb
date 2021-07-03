include_set Abstract::MetricChild, generation: 1
include_set Abstract::PublishableField

def query
  "#{answer_id_field} in (#{answer_relation.select(:answer_id).to_sql})"
end

def answer_relation
  metric_card.fetch(:metric_answer).format.research_query.lookup_query
end

def answer_id_field
  inverse? ? :inverse_answer_id : :answer_id
end

def item_type
  :relationship_answer
end

format do
  def relationship_query
    card.query
  end
end
