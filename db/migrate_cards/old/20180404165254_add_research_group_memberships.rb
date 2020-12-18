# -*- encoding : utf-8 -*-

class AddResearchGroupMemberships < Cardio::Migration
  def up
    merge_cards ["user+research_group+*type_plu_right+*structure"]
  end
end
