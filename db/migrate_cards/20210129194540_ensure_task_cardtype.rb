# -*- encoding : utf-8 -*-

class EnsureTaskCardtype < Cardio::Migration
  def up
    ensure_code_card "Task", type: "Cardtype"
  end
end
