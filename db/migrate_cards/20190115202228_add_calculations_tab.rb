# -*- encoding : utf-8 -*-

class AddCalculationsTab < Card::Migration
  def up
    ensure_card "Calculation", codename: "calculation"
  end
end
