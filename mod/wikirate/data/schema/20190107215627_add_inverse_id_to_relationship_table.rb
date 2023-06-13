# -*- encoding : utf-8 -*-

class AddInverseIdToRelationshipTable < Cardio::Migration::Schema
  def up
    add_column :relationships, :inverse_metric_id, :integer
  end
end
