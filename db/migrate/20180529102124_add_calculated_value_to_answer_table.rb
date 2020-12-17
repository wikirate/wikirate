# -*- encoding : utf-8 -*-

class AddCalculatedValueToAnswerTable < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :overridden_value, :string
  end
end
