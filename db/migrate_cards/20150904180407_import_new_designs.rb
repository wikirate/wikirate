# -*- encoding : utf-8 -*-

class ImportNewDesigns < Card::Migration
  def up
    import_json "new_designs.json"
    
  end
end
