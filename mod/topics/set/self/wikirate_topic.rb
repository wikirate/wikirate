include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch

format :html do
  view :titled_content, template: :haml
end
