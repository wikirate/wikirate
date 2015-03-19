# -*- encoding : utf-8 -*-

class ImportNewHomepage < Card::Migration
  def up
    import_json "new_homepage.json"
    
  end
end
