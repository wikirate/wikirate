# -*- encoding : utf-8 -*-

class CodifyCompanyCategory < Cardio::Migration
  def up
    ind = ensure_code_card "Commons+Company Category",
                           codename: "company_category", type: :metric
    ind.metric_type_card.update! content: "Formula"
  end
end
