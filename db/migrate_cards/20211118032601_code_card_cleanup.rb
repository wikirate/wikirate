# -*- encoding : utf-8 -*-

class CodeCardCleanup < Cardio::Migration
  DECODABLES = %i[
    commons_has_brands
    commons_industry
    commons_is_brand_of
    commons_supplied_by
    commons_supplier_of
  ]

  DELETABLES = %i[

  ]
  def up
  end

  def remove_ccc_codenames
    Card.where("codename like 'ccc_%'").update_all codename: null
  end
end
