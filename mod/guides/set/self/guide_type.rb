format :html do
  SUPPORT_CARDS = ["FAQ", "Glossary", "Talk to us"].freeze

  def layout_name_from_rule
    :guide_layout
  end

  before :content_formgroups do
    voo.edit_structure = %i[title description list]
  end

  def support_cards
    SUPPORT_CARDS
  end

  view :guide_page, template: :haml, wrap: :slot
end
