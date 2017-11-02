# -*- encoding : utf-8 -*-

class FixBrowsePages < Card::Migration
  def up
    merge_cards %w[metric+*self+*structure
                   topic+*self+*structure
                   company+*self+*structure]
  end
end
