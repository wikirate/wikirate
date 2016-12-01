# -*- encoding : utf-8 -*-

class ScriptVega < Card::Migration
  def up
    add_script "vega", type_id: Card::JavaScriptID,
               to: "script: wikirate scripts"
  end
end
