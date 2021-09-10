include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicFilter

format :html do
  view :titled_content, template: :haml
end
