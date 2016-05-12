# -*- encoding : utf-8 -*-

# "<Metric>+metric value filter" cards provide interface for filtering metric
# values.  This card is needed for codename hookin.
class AddMetricValueFilter < Card::Migration
  def up
    Card.create! name: 'metric value filter', codename: 'metric_value_filter'
  end
end
