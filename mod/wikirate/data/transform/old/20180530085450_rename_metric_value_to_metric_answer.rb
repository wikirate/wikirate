# -*- encoding : utf-8 -*-

class RenameMetricValueToMetricAnswer < Cardio::Migration::Transform
  def up
    update_card :metric_value, name: "Answer", codename: "metric_answer"
  end
end
