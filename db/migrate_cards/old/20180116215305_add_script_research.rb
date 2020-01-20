# -*- encoding : utf-8 -*-

class AddScriptResearch < Card::Migration
  def up
    add_script "research",
               type_id: Card::CoffeeScriptID,
               to: "script: wikirate scripts"
  end
end
