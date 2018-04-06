# -*- encoding : utf-8 -*-

class AddResearchGroupMemberships < Card::Migration
  def up
    merge_cards ["user+research_group+*type_plu_right+*structure"]
  end
end
