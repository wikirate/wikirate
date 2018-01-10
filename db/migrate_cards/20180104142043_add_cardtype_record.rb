# -*- encoding : utf-8 -*-

class AddCardtypeRecord < Card::Migration
  def up
    ensure_card "Record", type: Card::CardtypeID, codename: "record"
    Card::Cache.reset_all

    type_to_record left: { type_id: Card::MetricID },
                   right: { type_id: Card::WikirateCompanyID }
    type_to_record left: { type_id: Card::RecordID }, right: { type_id: Card::UserID }
  end

  def type_to_record query
    ids = Card.search query.merge(return: :id)
    Card.where(id: ids).update_all type_id: Card::RecordID
  end
end
