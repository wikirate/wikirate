# -*- encoding : utf-8 -*-

class MetricEditor < Card::Migration
  def up
    create_card! name: '*variables', codename: 'variables'
    create_card! name: '*variables+*right+*default',
                 type_id: Card::SessionID
    Card::Cache.reset_all
  end
end
