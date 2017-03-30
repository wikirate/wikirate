# -*- encoding : utf-8 -*-

class StyleWikirateProgressBar < Card::Migration
  def up
    add_style "wikirate progress bar",
              to: "customized classic skin"
  end
end
