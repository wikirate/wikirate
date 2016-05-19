# -*- encoding : utf-8 -*-

class ImportProfilePageFix < Card::Migration
  def up
    import_json "profile_page_fix.json"
  end
end
