# -*- encoding : utf-8 -*-

class AddEditorIdToAnswerTable < Cardio::Migration::DeckStructure
  def up
    add_column :answers, :editor_id, :integer
  end
end
