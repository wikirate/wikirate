# -*- encoding : utf-8 -*-

class ImportCampaignProjectLayoutUpdate < Card::Migration
  def up
    import_json "campaign_project_layout_update.json"
  end
end
