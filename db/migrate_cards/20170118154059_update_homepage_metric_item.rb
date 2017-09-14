# -*- encoding : utf-8 -*-

class UpdateHomepageMetricItem < Card::Migration
  def up
    merge_cards "homepage_metric_item"
  end
end
