# -*- encoding : utf-8 -*-

class CodeCardCleanup < Cardio::Migration
  DELETABLES = %i[

  ]
  def up
  end

  def remove_ccc_codenames
    Card.where("codename like 'ccc_%'").update_all codename: null
  end
end
