# -*- encoding : utf-8 -*-

class SeparateMetricVariables < Card::Migration
  def up
    ensure_card "*metric variables", codename: :metric_variables
  end
end
