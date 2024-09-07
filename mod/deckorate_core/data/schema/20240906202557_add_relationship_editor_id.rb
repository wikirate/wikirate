# -*- encoding : utf-8 -*-

class AddRelationshipEditorId < Cardio::Migration::Schema
  def up
    add_column :relationships, :editor_id, :integer
  end
end
