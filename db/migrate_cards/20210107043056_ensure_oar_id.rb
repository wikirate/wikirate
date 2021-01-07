# -*- encoding : utf-8 -*-

class EnsureOarId < Cardio::Migration
  def up
    ensure_code_card "OAR id"
  end
end
