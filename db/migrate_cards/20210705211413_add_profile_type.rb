# -*- encoding : utf-8 -*-

class AddProfileType < Cardio::Migration
  def up
    ensure_code_card "Profile Type"
  end
end
