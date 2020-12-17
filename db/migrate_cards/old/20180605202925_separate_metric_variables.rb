# -*- encoding : utf-8 -*-

class SeparateMetricVariables < Cardio::Migration
  def up
    ensure_card "*metric variables", codename: :metric_variables
  end
end
