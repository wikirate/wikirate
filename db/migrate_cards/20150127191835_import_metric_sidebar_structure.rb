# -*- encoding : utf-8 -*-

class ImportMetricSidebarStructure < Wagn::Migration
  def up
    import_json "metric_sidebar_structure.json"
    
  end
end
