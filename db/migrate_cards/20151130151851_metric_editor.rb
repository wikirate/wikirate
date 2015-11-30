# -*- encoding : utf-8 -*-

class MetricEditor < Card::Migration
  def up
    create_card! name: '*formula input', codename: 'formula_input'
    create_card! name: '*formula input+*right+*default',
                 type_id: Card::SessionID
  end
end
