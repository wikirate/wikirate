# -*- encoding : utf-8 -*-

class ImportYinyang < Card::Migration
  def up
    import_json "yinyang.json"
    
  end
end
