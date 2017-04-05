# cache # of metrics with values for this company (=_left)
include_set Abstract::CachedCount
include_set Type::SearchType

def virtual?
  true
end

def search args={}
  metric_ids = Answer.where(company_id: left.id).pluck(:metric_id).uniq
  case args[:return]
  when :id
    metric_ids
  when :count
    metric_ids.count
  when :name
    metric_ids.map { |id| Card.fetch_name id }
  else
    metric_ids.map { |id| Card.fetch id }
  end
end

# recount metrics related to company whenever a value is created or deleted
recount_trigger Type::MetricValue, on: [:create, :delete] do |changed_card|
  if (company_name = changed_card.company_name)
    Card.fetch company_name.to_name.trait(:metric)
  end
end
