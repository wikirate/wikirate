include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch

format :html do
  before(:filtered_content) { voo.items[:view] = :box }
end
