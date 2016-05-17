# -*- encoding : utf-8 -*-

class ScriptSourcePreview < Card::Migration
  def up
    create_or_update name: "script: source preview",
                     type_id: 5466,
                     codename: "script_source_preview"
  end
end
