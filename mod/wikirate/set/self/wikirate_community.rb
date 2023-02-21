include_set Abstract::FluidLayout
include_set Abstract::FancyCounts
include_set Abstract::AboutPages

format :html do
  def count_categories
    %i[research_group project]
  end

  def edit_fields
    %i[description general_overview blurb]
  end

  def breadcrumb_title
    "Our Community"
  end

  view :page, template: :haml
end
