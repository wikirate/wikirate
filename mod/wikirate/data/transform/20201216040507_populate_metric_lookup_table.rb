# -*- encoding : utf-8 -*-

class PopulateMetricLookupTable < Cardio::Migration::Transform  def up
    ::Metric.refresh_all
  end
end
