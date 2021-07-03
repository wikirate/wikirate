include_set Abstract::MetricChild, generation: 1
include_set Abstract::PublishableField

def query
  { metric_id: left.id }
end

def item_type
  :relationship_answer
end

format do
  def relationship_query
    card.query
  end

  def answer_relation
    metric_card.fetch(:metric_answer).format.research_query.lookup_query
  end

  def relationship_relation
    super.where("#{answer_id_field} in (#{answer_relation.select(:answer_id).to_sql})")
  end

  def answer_id_field
    inverse? ? :inverse_answer_id : :answer_id
  end
end
