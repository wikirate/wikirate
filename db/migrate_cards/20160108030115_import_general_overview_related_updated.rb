# -*- encoding : utf-8 -*-

class ImportGeneralOverviewRelatedUpdated < Card::Migration
  def up
    import_json "general_overview_related_updated.json"
    
  end
end
