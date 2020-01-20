# -*- encoding : utf-8 -*-

class UpdateStandardHeadExtra < Card::Migration
  def up
    merge_cards "standard_head_extras"
  end
end
