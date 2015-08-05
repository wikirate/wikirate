# -*- encoding : utf-8 -*-

class ImportNewSolocomplete < Card::Migration
  def up
    import_json "new_solocomplete.json"
    
  end
end
