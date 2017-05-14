# -*- encoding : utf-8 -*-

class ValueTypeDefaultType < Card::Migration
  def up
    ensure_card "value type+*right+*default", type_id: Card::PointerID
  end
end
