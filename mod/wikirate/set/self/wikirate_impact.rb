include_set Abstract::Jumbotron

format :html do
  def edit_fields
    %i[description general_overview]
  end

  view :page, template: :haml


end
