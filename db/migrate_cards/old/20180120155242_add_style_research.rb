# -*- encoding : utf-8 -*-

class AddStyleResearch < Cardio::Migration
  def up
    add_style "research",
              type_id: Card::ScssID,
              to: "customized classic skin"
  end
end
