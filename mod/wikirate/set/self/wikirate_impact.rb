include_set Abstract::FluidLayout
include_set Abstract::AboutPages

format :html do
  def edit_fields
    absolutize_edit_fields %i[main_impact_heading contribute_heading]
  end

  def breadcrumb_title
    "Impact"
  end

  view :page, template: :haml, cache: :yes
end
