include_set Abstract::CachedCount
include_set Abstract::MetricSearch

recount_trigger :type, :metric, on: [:create, :delete] do |_changed_card|
  Card[:metric]
end

def count
  MetricQuery.new({}).count
end

format :html do
  before(:filtered_content) { voo.items[:view] = :box }
end

format :json do
  def complete_or_match_search limit: 10
    paging = { limit: limit }
    sort = { metric_title: :asc }
    query = term_param ? { metric_keyword: term_param } : {}
    MetricQuery.new(query, sort, paging).run
  end
end
