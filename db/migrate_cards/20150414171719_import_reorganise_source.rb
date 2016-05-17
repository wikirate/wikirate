# -*- encoding : utf-8 -*-

class ImportReorganiseSource < Card::Migration
  def up
    # update the type and its codename
    source_card = Card["Source"]
    source_card.type_id = Card::CardtypeID
    source_card.codename = "source"
    source_card.save!
    Card.where(type_id: Card::WebpageID).update_all(type_id: Card::SourceID)
    # default website for source+file
    Card.create name: "wikirate.org", type_id: Card::WikirateWebsiteID

    import_json "reorganise_source.json"
  end
end
