# -*- encoding : utf-8 -*-

class SpecialPointer < Card::Migration
  def up
    sp = Card.create! :name=>"Special Pointer",:type_id=>Card::CardtypeID,:codename=>"special_pointer"
    Card.create! :name=>"production_export",:type_id=>sp.id
  end
end
