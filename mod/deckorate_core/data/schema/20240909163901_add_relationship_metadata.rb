# -*- encoding : utf-8 -*-

class AddRelationshipMetadata < Cardio::Migration::Schema
  def up
    add_column :relationships, :created_at, :datetime
    add_column :relationships, :creator_id, :integer
  end
end
