# -*- encoding : utf-8 -*-

class StyleFilter < Card::Migration
  def up
    add_style "filter", to: "customized classic skin"
  end
end
