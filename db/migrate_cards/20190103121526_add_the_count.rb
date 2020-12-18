# -*- encoding : utf-8 -*-

class AddTheCount < Cardio::Migration
  def up
    ensure_code_card "the count"
  end
end
