# -*- encoding : utf-8 -*-

class MetricFields < Card::Migration
  def up
    create_or_update 'Methodology', codename: 'methodology'
    create_or_update 'Value Type', codename: 'value_type'
  end
end
