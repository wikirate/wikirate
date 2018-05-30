# -*- encoding : utf-8 -*-

class AddCalculatedValueToAnswerTable < Card::Migration::DeckStructure
  def up
    add_column :answers, :calculated_value, :string
  end
end
