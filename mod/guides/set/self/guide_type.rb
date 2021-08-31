format :html do
  def layout_name_from_rule
    :guide_layout
  end

  before :content_formgroups do
    voo.edit_structure = %i[description list]
  end

  view :guide_page, template: :haml, wrap: :slot
end
