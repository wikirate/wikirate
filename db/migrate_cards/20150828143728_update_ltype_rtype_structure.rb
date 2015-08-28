# -*- encoding : utf-8 -*-

class UpdateLtypeRtypeStructure < Card::Migration
  def up
    Card['*ltype rtype+*right+*structure'].update_attributes! :content=>'{"left":{"type":"_LL"}, "right":{"type":"_LR"}}'
  end
end
