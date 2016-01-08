# -*- encoding : utf-8 -*-

class ImportGeneralOverviewRelated < Card::Migration
  def up
    import_json "general_overview_related.json"
    
  end
end
