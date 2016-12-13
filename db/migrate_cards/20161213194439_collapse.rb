# -*- encoding : utf-8 -*-

class Collapse < Card::Migration
  def up
    add_script 'collapse',
               type_id: Card::CoffeeScriptID,
               to: 'script: wikirate scripts'
  end
end
