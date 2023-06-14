# -*- encoding : utf-8 -*-

class AnswerVerificationLevel < Cardio::Migration::Schema
  def up
    add_column :answers, :verification, :integer
  end
end
