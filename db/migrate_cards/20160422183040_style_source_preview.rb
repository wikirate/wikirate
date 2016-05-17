# -*- encoding : utf-8 -*-

class StyleSourcePreview < Card::Migration
  def up
    create_or_update name: "style: source preview",
                     type_id: 3819,
                     codename: "style_source_preview"
  end
end
