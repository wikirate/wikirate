# -*- encoding : utf-8 -*-

class RenameMetricValueToAnswer < Cardio::Migration::Transform
  def up
    update_card :metric_value, name: "Answer", codename: "answer"
  end
end
