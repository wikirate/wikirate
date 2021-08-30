format :html do
  def layout_name_from_rule
    :guide_layout
  end

  view :guide_page, template: :haml, wrap: :slot
end
