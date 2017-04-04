# cache # of companies with values for metric (=_left)
include_set Abstract::CachedCount
include_set Type::SearchType

def virtual?
  true
end

def search args={}
  company_ids = Answer.where(metric_id: left_id).pluck(:company_id).uniq
  case args[:return]
  when :id
    company_ids
  when :count
    company_ids.count
  when :name
    company_ids.map { |id| Card.fetch_name id }
  else
    company_ids.map { |id| Card.fetch id }
  end
end

ensure_set { Type::MetricValue }

# recount number of companies for a given metric when a Metric Value card is
# created or deleted
recount_trigger Type::MetricValue, on: [:create, :delete] do |changed_card|
  changed_card.metric_card.fetch(trait: :wikirate_company)
end
