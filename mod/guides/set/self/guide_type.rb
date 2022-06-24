include_set Abstract::Jumbotron

SUPPORT_CARDS = ["FAQ", "Glossary", "Talk to us"].freeze

format :html do
  before :content_formgroups do
    voo.edit_structure = %i[title description list]
  end

  before(:page) { voo.title = "Guides" }

  view :page, template: :haml, wrap: :slot

  def support_cards
    SUPPORT_CARDS
  end
end
