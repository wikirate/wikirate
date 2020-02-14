include_set Abstract::HamlFile

format do
  def organization_cards
    Card.fetch(:organizations_using_wikirate).item_cards
  end
end
