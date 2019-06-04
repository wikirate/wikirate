# -*- encoding : utf-8 -*-

class AddInverseIdToRelationshipTable < ActiveRecord::Migration[5.2]
  def up
    add_column :relationships, :inverse_metric_id, :integer
  end
end
