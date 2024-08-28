include_set Abstract::ProjectSearch

format :html do
  view :titled_content, template: :haml

  def edit_fields
    %i[description featured]
  end
end
