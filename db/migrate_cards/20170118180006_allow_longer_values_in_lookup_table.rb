# -*- encoding : utf-8 -*-

class AllowLongerValuesInLookupTable < ActiveRecord::Migration
  def up
    remove_index :answers, column: :value
    add_index :answers, :value, name: "value_index", length: 100
    change_column :answers, :value, :string, limit: 1024
  end
end
