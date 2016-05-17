# -*- encoding : utf-8 -*-

class ImportMetricSidebarStructure < Card::Migration
  def up
    import_json "metric_sidebar_structure.json"
  end
end
