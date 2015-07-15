# -*- encoding : utf-8 -*-

class ImportCaching < Card::Migration
  def up
    import_json "caching.json"
    
  end
end
