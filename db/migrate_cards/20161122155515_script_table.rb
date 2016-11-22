# -*- encoding : utf-8 -*-

class ScriptTable < Card::Migration
  def up
    create_or_update name: 'script: table',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_table'
    script_card = Card.fetch("script: wikirate scripts")
    script_card.add_item! "script: table"
  end
end
