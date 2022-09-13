# -*- encoding : utf-8 -*-

class AddOpenFlags < ActiveRecord::Migration[6.1]
  def up
    add_column :answers, :open_flags, :integer, if_not_exists: true
    remove_column :answers, :check_requester, if_exists: true
  end
end
