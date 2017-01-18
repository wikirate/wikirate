# -*- encoding : utf-8 -*-

class AllowLongerValuesInLookupTable < ActiveRecord::Migration
  def up
    change_column :answers, :value, :string, limit: 1000
  end
end
