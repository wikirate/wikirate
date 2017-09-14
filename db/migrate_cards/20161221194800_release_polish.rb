# -*- encoding : utf-8 -*-

class ReleasePolish < Card::Migration
  def up
    merge_cards %(homepage_topic_item source+*self+*structure)
  end
end
