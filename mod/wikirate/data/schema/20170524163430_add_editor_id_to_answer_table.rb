# -*- encoding : utf-8 -*-

class AddEditorIdToAnswerTable < Cardio::Migration::Schema
  def up
    add_column :answers, :editor_id, :integer
  end
end
