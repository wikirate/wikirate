include_set Abstract::FluidLayout


format :html do
  def edit_fields
    %i[description general_overview]
  end

  def breadcrumb_title
    "Our Impact"
  end

  view :page, template: :haml
end
