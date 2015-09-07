# -*- encoding : utf-8 -*-

class ImportSimpleRepairs2 < Card::Migration
  def up
    import_json "simple_repairs2.json"
    
  end
end
