# -*- encoding : utf-8 -*-

class RenameMetricValueToRecord < Cardio::Migration::Transform
  def up
    update_card :metric_value, name: "Answer", codename: "record"
  end
end
