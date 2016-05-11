# -*- encoding : utf-8 -*-

class AddMetricValueFilter < Card::Migration
  def up
    Card.create! name: 'metric value filter', codename: 'metric_value_filter'
  end
end
