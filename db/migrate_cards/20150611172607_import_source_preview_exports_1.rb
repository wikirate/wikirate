# -*- encoding : utf-8 -*-

class ImportSourcePreviewExports1 < Card::Migration
  def up
    import_json "source_preview_exports_1.json"
    
  end
end
