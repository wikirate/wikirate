# -*- encoding : utf-8 -*-

class AddResearchGroup < Card::Migration
  def up
    merge_cards ["research_group", "researcher"]
  end
end
