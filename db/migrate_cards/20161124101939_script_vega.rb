# -*- encoding : utf-8 -*-

class ScriptVega < Card::Migration
  def up
    create_or_update name: 'script: vega',
                     type_id: Card::JavaScriptID,
                     codename: 'script_vega'
    script_card = Card.fetch("script: wikirate scripts")
    script_card.add_item! "script: vega"
  end
end
