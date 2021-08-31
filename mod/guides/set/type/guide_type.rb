card_accessor :body

format :html do
  def layout_name_from_rule
    :guide_layout
  end

  before :content_formgroups do
    voo.edit_structure = %i[description body]
  end

  view :box_middle do
    field_nest :description
  end

  view :box_bottom do
    link_to_card card, "View Guide"
  end

  view :guide_page, template: :haml, wrap: :slot
  view :sidebar_nav, template: :haml, cache: :never
  view :guide_paging do
    "hello world"
  end

  def expanded?
    parent&.parent&.card == card
  end

  def subheaders
    # start new format so we get fully rendered html (no nest stubs)
    Nokogiri::HTML(card.body_card.format.render_core).css("h2").sort
  end
end
