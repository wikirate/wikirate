# -*- encoding : utf-8 -*-

class ImportMetricTypes < Card::Migration
  def up
    import_json 'metric_types.json'
    create_or_update name: 'script: drag and drop',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_drag_and_drop'
    create_or_update name: 'script: metrics',
                     type_id: Card::CoffeeScriptID,
                     codename: 'script_metrics'
    create_or_update name: 'style: drag and drop',
                     type_id: Card::ScssID,
                     codename: 'style_drag_and_drop'
    create_or_update name: 'style: metrics',
                     type_id: Card::ScssID,
                     codename: 'style_metrics'
    create_or_update name: 'style: wikirate bootstrap common',
                     type_id: Card::ScssID,
                     codename: 'style_wikirate_bootstrap_common'
  end
end
