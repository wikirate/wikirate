# -*- encoding : utf-8 -*-

class AddBenchmarkLookup < Cardio::Migration::Schema
  def up
    add_column :metrics, :benchmark, :boolean
  end
end
