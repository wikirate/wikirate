# -*- encoding : utf-8 -*-

class AnswerVerificationLevel < Cardio::Migration
  def up
    add_column :answers, :verification_level, :integer
  end
end
