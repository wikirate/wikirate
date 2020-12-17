# -*- encoding : utf-8 -*-

class MoveNavBarToCode < Cardio::Migration
  def up
    ensure_card "nav bar", codename: "nav_bar"
  end
end
