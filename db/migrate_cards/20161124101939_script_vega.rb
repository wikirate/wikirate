# -*- encoding : utf-8 -*-

class ScriptVega < Card::Migration
  def up
    add_script 'd3',
               type_id: Card::JavaScriptID,
               to: 'script:libraries'
    add_script "vega", type_id: Card::JavaScriptID,
               to: "script: libraries"
    add_script 'metric_chart',
               type_id: Card::CoffeeScriptID,
               to: 'script: wikirate scripts'
  end
end
