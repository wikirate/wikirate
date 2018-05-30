# -*- encoding : utf-8 -*-

class RenameMetricValueToMetricAnswer < Card::Migration
  def up
    update_card :metric_value,
                name: "Metric Answer", codename: "metric_answer"
  end
end
