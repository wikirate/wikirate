include_set Abstract::FluidLayout

format :html do
  def edit_fields
    %i[description general_overview blurb list]
  end

  view :page, template: :haml

  def breadcrumb_title
    "Our Data"
  end
end
