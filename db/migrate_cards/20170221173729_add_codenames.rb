# -*- encoding : utf-8 -*-

class AddCodenames < Card::Migration
  def up
    ensure_card "question", codename: "question"
  end
end
