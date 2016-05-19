# -*- encoding : utf-8 -*-

class ImportSourcePreviewStuff < Card::Migration
  def up
    import_json "source_preview_stuff.json"
  end
end
