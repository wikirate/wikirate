# -*- encoding : utf-8 -*-

class AddRangeCodename < Card::Migration
  def up
    ensure_card "Range", codename: :range
  end
end
