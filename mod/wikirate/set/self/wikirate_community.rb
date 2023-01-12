include_set Abstract::FluidLayout

format :html do
  def edit_fields
    %i[description general_overview blurb]
  end

  def breadcrumb_title
    "Our Community"
  end

  view :page, template: :haml
end
