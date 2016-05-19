# -*- encoding : utf-8 -*-

class ImportTabContent < Card::Migration
  def up
    import_json "tab_content.json"
  end
end
