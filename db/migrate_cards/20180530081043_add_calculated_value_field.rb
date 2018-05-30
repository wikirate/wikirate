# -*- encoding : utf-8 -*-

class AddCalculatedValueField < Card::Migration
  def up
    ensure_card "calculated value", codename: "calculated_value"
  end
end
