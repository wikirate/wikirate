# -*- encoding : utf-8 -*-

class ImportNewClaimItemForModal < Card::Migration
  def up
    import_json "new_claim_item_for_modal.json"
  end
end
