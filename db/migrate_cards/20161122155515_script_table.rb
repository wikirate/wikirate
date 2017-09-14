# -*- encoding : utf-8 -*-

class ScriptTable < Card::Migration
  def up
    add_script "table", to: "script: wikirate scripts"
  end
end
