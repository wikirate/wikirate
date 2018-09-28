# -*- encoding : utf-8 -*-

class AddCalculatingFlag < Card::Migration::DeckStructure
  def up
    add_column :answers, :calculating, :boolean
  end
end
