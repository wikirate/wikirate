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
