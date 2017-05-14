# -*- encoding : utf-8 -*-

class FilterSearchScript < Card::Migration
  def up
    ensure_card "script: filter search",
                type_id: Card::CoffeeScriptID,
                codename: 'script_filter_search'
    script_card = Card.fetch("script: wikirate scripts")
    script_card.add_item! "script: filter search"
  end
end
