# -*- encoding : utf-8 -*-

class ImportTextCodename < Card::Migration
  def up
    import_json "text_codename.json"
    
  end
end
