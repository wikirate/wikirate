# -*- encoding : utf-8 -*-

class AddResearchGroup < Card::Migration
  def up
    merge_cards [
      "research_group",
      "researcher",
      "research group+Project+*type_plus_right+*default",
      "research group+Metric+*type_plus_right+*default"
    ]
  end
end
