# -*- encoding : utf-8 -*-

class Wikipedia < Card::Migration
  def up
    ensure_card "Wikipedia", codename: "wikipedia"
    Card::Cache.reset_all
    ensure_card [:wikipedia, :right, :default], type_id: Card::PhraseID
  end
end
