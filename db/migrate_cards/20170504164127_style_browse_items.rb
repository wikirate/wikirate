# -*- encoding : utf-8 -*-

class StyleBrowseItems < Card::Migration
  def up
    add_style "style browse items",
                type_id: Card::ScssID,
                to: "customized classic skin"
  end
end
