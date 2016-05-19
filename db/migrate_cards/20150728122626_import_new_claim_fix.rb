# -*- encoding : utf-8 -*-

class ImportNewClaimFix < Card::Migration
  def up
    import_json "new_claim_fix.json"
  end
end
