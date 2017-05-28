# -*- encoding : utf-8 -*-

class DeleteOldStructures < Card::Migration
  def up
    delete "metric value type edit structure"
    delete "creator credit"
  end
end
