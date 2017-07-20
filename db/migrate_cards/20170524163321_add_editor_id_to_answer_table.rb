# -*- encoding : utf-8 -*-

class AddEditorIdToAnswerTable < ActiveRecord::Migration
  def up
    add_column :answers, :editor_id, :integer
  end
end
