# -*- encoding : utf-8 -*-

class EmailFix < Card::Migration
  def up
    merge_cards "email header"
  end
end
