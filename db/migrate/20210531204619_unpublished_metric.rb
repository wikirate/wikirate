# -*- encoding : utf-8 -*-

class UnpublishedMetric < Cardio::Migration
  def up
    add_column :metrics, :unpublished, :boolean
  end
end
