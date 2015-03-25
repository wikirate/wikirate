# -*- encoding : utf-8 -*-

class ImportWagnySourcePreview < Card::Migration
  def up
    import_json "wagny_source_preview.json"
    
  end
end
