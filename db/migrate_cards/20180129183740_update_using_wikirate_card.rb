# -*- encoding : utf-8 -*-

class UpdateUsingWikirateCard < Card::Migration
  def up
    merge_cards ["Using WikiRate", "*css"]
  end
end
