# -*- encoding : utf-8 -*-

class AddStyleResearch < Card::Migration
  def up
    add_style "research",
              type_id: Card::ScssID,
              to: "customized classic skin"
  end
end
