# -*- encoding : utf-8 -*-

class AddResearchGroup < Card::Migration
  def up
    merge_cards [
      "research_group",
      "researcher",
      "research_group+project+*type_plu_right+*default",
      "research_group+metric+*type_plu_right+*default"
    ]
  end
end
