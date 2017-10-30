# -*- encoding : utf-8 -*-

class RenameMetricValueImportFile < Card::Migration
  def up
    return unless Card::Codename.exists? :metric_value_import_file
    Card[:metric_value_import_file].update_attributes! codename: "answer_import_file",
                                                       name: "Metric Answer Import File"
  end
end
