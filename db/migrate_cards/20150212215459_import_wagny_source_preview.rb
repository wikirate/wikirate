# -*- encoding : utf-8 -*-

class ImportWagnySourcePreview < Wagn::Migration
  def up
    import_json "wagny_source_preview.json"
    
  end
end
