# -*- encoding : utf-8 -*-

class AllowLongerValuesInLookupTable < ActiveRecord::Migration[4.2]
  def up
    # remove_index :answers, name: "value_index"
    # add_index :answers, :value, name: "value_index", length: 100
    # add_index :answers, :numeric_value, name: "numeric_value_index"
    # change_column :answers, :value, :string, limit: 1024
  end
end
