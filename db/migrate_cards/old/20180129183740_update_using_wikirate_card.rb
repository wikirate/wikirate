# -*- encoding : utf-8 -*-

class UpdateUsingWikirateCard < Cardio::Migration
  def up
    merge_cards ["Using WikiRate", "*css"]
  end
end
