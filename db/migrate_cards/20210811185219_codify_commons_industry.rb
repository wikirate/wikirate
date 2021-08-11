# -*- encoding : utf-8 -*-

class CodifyCommonsIndustry < Cardio::Migration
  def up
    ind = ensure_code_card "Commons+Industry", type: :metric
    ind.metric_type_card.update! content: "Formula"
  end
end
