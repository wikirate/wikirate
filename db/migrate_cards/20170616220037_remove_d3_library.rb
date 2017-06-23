# -*- encoding : utf-8 -*-

class RemoveD3Library < Card::Migration
  def up
    Card["script: libraries"].drop_item! "script: d3"
    Card["script: d3"].update_attributes! codename: nil
    Card::Cache.reset_all
    Card["script: d3"].delete
  end
end
