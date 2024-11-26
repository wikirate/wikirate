# -*- encoding : utf-8 -*-

# answer lookup fields for new flagging pattern
class AddOpenFlags < Cardio::Migration::Schema
  def up
    add_column :answer, :open_flags, :integer, if_not_exists: true
    remove_column :answer, :check_requester, if_exists: true
  end
end
