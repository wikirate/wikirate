# -*- encoding : utf-8 -*-

class AddCalculatedValueField < Card::Migration
  def up
    ensure_card "overridden value", codename: "overridden_value"
  end
end
