# -*- encoding : utf-8 -*-

class AddDescendantMetricType < Cardio::Migration
  def up
    merge_cards %w[descendant descendant+description metric_type]
  end
end
