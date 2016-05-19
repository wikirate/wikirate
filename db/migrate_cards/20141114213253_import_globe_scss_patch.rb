# -*- encoding : utf-8 -*-

class ImportGlobeScssPatch < Card::Migration
  def up
    import_json "globe_scss_patch.json"
  end
end
