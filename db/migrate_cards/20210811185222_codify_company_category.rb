# -*- encoding : utf-8 -*-

class CodifyCompanyCategory < Cardio::Migration
  def up
    metric = Card.where(codename: "company_category").take
    if metric&.type_code == :metric
      metric&.update_column :codename, "commons_company_category"
    end
    ensure_code_card "Company Category",
                     codename: "company_category",
                     type: :metric_title
    ind = ensure_code_card "Commons+Company Category",
                           codename: "commons_company_category",
                           type: :metric
    ind.metric_type_card.update! content: "Formula"
  end
end
