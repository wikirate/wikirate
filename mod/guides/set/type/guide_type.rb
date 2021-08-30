format :html do
  def layout_name_from_rule
    :guide_layout
  end

  before :content_formgroups do
    voo.edit_structure = [
      :description,
      :body
    ]
  end

  view :box_middle do
    field_nest :description
  end

  view :box_bottom do
    link_to_card card, "View Guide"
  end

  view :guide_page, template: :haml, wrap: :slot
  view :sidebar_nav, template: :haml
end
