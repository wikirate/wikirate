# -*- encoding : utf-8 -*-

class AddTheCount < Card::Migration
  def up
    ensure_code_card "the count"
  end
end
