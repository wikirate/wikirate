# -*- encoding : utf-8 -*-

class AddCalculationsTab < Cardio::Migration
  def up
    ensure_card "Calculation", codename: "calculation"
  end
end
