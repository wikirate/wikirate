# -*- encoding : utf-8 -*-

class AddSubtopic < Card::Migration
  def up
    ensure_code_card "subtopic"
    ensure_code_card "supertopic"
  end
end
