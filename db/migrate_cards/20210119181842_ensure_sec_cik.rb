# -*- encoding : utf-8 -*-

class EnsureSecCik < Cardio::Migration
  def up
    ensure_code_card "SEC CIK"
  end
end
