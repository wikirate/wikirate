# -*- encoding : utf-8 -*-

class AddValueTypeList < Cardio::Migration
  def up
    merge_cards "value_type"
  end
end
