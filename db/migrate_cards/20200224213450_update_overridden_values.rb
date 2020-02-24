# -*- encoding : utf-8 -*-

class UpdateOverriddenValues < Card::Migration
  def up
    Answer.where(overridden_value: "").update_all(overridden_value: nil)
  end
end
