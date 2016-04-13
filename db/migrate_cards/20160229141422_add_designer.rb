# -*- encoding : utf-8 -*-

class AddDesigner < Card::Migration
  def up
    create_or_update! 'Designer', codename: 'designer'
  end
end
