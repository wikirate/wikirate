# -*- encoding : utf-8 -*-

class AddDescendantMetricType < Card::Migration
  def up
    merge_cards %w[descendant descendant+description metric_type]
  end
end
