# -*- encoding : utf-8 -*-

class ReleasePolish < Card::Migration
  def up
    merge %(homepage_topic_item source+*self+*structure)
  end
end
