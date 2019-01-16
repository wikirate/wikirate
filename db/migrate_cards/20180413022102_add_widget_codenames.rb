# -*- encoding : utf-8 -*-

class AddWidgetCodenames < Card::Migration
  def up
    widget_cards = { commons_supplier_of: "Commons+Supplier of",
                     company_address: "Clean_Clothes_Campaign+Address" }

    # rename CCC metric if it exists
    if (supplier_card = Card["Clean Clothes Campaign+Supplier Of"])
      supplier_card.update! name: widget_cards[:commons_supplier_of],
                                       update_referers: true,
                                       silent_change: true
    end

    # add codenames to cards
    widget_cards.each do |codename, cardname|
      ensure_card cardname, codename: codename, type_id: Card::MetricID
    end
    Card::Codename.reset_cache
  end
end
