# -*- encoding : utf-8 -*-

class CodifyCommonsIndustry < Cardio::Migration
  def up
    if (c = Card.where(codename: "commons+industry").take)
      c.update_column :codename, "commons_industry"
    end
    ind = ensure_code_card "Commons+Industry", codename: "commons_industry", type: :metric
    ind.metric_type_card.update! content: "Formula"
  end
end
