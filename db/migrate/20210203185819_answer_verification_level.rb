# -*- encoding : utf-8 -*-

class AnswerVerificationLevel < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :verification, :integer
  end
end
