include_set Abstract::MetricChild, generation: 1
include_set Abstract::PublishableField

def query
  { metric_id: left_id }
end

format do
  def relationship_query
    card.query
  end

  def answer_relation
    metric_card.fetch(:metric_answer).format.research_query.lookup_query
  end

  def relationship_relation
    puts "answer query sql: #{answer_relation.to_sql}"

    super
  end
end
