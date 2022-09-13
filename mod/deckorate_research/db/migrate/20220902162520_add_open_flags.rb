# -*- encoding : utf-8 -*-

# answer lookup fields for new flagging pattern
class AddOpenFlags < ActiveRecord::Migration[6.1]
  def up
    add_column :answers, :open_flags, :integer, if_not_exists: true
    remove_column :answers, :check_requester, if_exists: true
  end
end
