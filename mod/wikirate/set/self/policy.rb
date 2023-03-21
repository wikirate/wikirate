include_set Abstract::Jumbotron
include_set Abstract::SectionHeader

format :html do
  before :page do
    voo.title = "A mutual understanding of how we act"
  end

  view :page, template: :haml
end
