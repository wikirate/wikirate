include_set Abstract::FluidLayout
include_set Abstract::AboutPages

# include_set Abstract::Jumbotron
# include_set Abstract::SectionHeader

format :html do
  def breadcrumb_title
    "Wikirate Policies"
  end

  before :page do
    voo.title = "A mutual understanding of how we act"
  end

  view :page, template: :haml
end
