# -*- encoding : utf-8 -*-

class B4UpdateNavbar < Card::Migration
  def up
    merge_cards %w[nav_bar nav_bar_menu]
  end
end
