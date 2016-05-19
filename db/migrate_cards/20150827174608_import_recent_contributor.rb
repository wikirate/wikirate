# -*- encoding : utf-8 -*-

class ImportRecentContributor < Card::Migration
  def up
    import_json "recent_contributor.json"
  end
end
