# -*- encoding : utf-8 -*-

class UnpublishedMetric < Cardio::Migration::Schema
  def up
    add_column :metrics, :unpublished, :boolean
  end
end
