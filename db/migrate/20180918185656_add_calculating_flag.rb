# -*- encoding : utf-8 -*-

class AddCalculatingFlag < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :calculating, :boolean
  end
end
