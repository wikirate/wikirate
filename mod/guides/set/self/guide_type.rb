format :html do
  SUPPORT_CARDS = ["FAQ", "Glossary", "Talk to us"].freeze

  def layout_name_from_rule
    :deckorate_jumbotron_layout
  end

  before :content_formgroups do
    voo.edit_structure = %i[title description list]
  end

  before(:page) { voo.title = "Guides" }

  def support_cards
    SUPPORT_CARDS
  end

  view :page, template: :haml, wrap: :slot
end
