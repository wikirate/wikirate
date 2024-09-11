include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::TopicSearch
include_set Abstract::FluidLayout

format :html do
  before(:filtered_content) { voo.items[:view] = :box }

  view :page, template: :haml
end
