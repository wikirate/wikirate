# cache # of values for left metric
include_set Abstract::CachedCount
include_set Type::SearchType

def virtual?
  true
end

def search args={}
  answer_rel = Answer.where(metric_id: left.id)
  case args[:return]
  when :id
    answer_rel.pluck(:answer_id)
  when :count
    answer_rel.count
  when :name
    answer_rel.pluck(:answer_id).map { |id| Card.fetch_name id }
  else
    answer_rel.pluck(:answer_id).map { |id| Card.fetch id }
  end
end

ensure_set { Type::MetricValue }

# recount number of answers for a given metric when a Metric Value card is
# created or deleted
recount_trigger Type::MetricValue, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :value)
end
