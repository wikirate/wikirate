# -*- encoding : utf-8 -*-

class ImportProgressBar < Card::Migration
  def up
    import_json "progress_bar.json"
    
  end
end
