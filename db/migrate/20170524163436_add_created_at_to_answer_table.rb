# -*- encoding : utf-8 -*-

class AddCreatedAtToAnswerTable < Card::Migration::DeckStructure
  def up
    # add_column :answers, :created_at, :datetime
  end
end
