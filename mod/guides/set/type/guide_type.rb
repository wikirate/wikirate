card_accessor :body

format :html do
  def layout_name_from_rule
    :deckorate_jumbotron_layout
  end

  before(:content_formgroups) { voo.edit_structure = %i[description body] }

  view :box_middle do
    field_nest :description
  end

  view :box_top, template: :haml
  view :box_bottom, template: :haml
  view :page, template: :haml, wrap: :slot
  view :sidebar_nav, template: :haml, cache: :never

  view :guide_paging do
    guide_names = guide_list_card&.item_names
    return unless (current_index = guide_names&.index card.name)

    haml :guide_paging, guide_names: guide_names, current_index: current_index
  end

  def guide_list_card
    Card[%i[guide_type list]]
  end

  def expanded?
    root.card == card
  end

  def subheaders
    # start new format so we get fully rendered html (no nest stubs)
    Nokogiri::HTML(card.body_card.format.render_core).css("h2").sort
  end
end
