# -*- encoding : utf-8 -*-

# record lookup fields for new flagging pattern
class AddOpenFlags < Cardio::Migration::Schema
  def up
    add_column :records, :open_flags, :integer, if_not_exists: true
    remove_column :records, :check_requester, if_exists: true
  end
end
