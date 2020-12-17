# -*- encoding : utf-8 -*-

class PopulateMetricLookupTable < Cardio::Migration
  def up
    ::Metric.refresh_all
  end
end
