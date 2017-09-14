# -*- encoding : utf-8 -*-

class AddEditorIdToAnswerTable < ActiveRecord::Migration[4.2]
  def up
    add_column :answers, :editor_id, :integer
  end
end
