# -*- encoding : utf-8 -*-

class AddWidgetCodenames < Card::Migration
  def up
    widget_cards = { commons_supplier_of: "Commons+Supplier of",
                     company_address: "Clean_Clothes_Campaign+Address" }

    if (supplier_card = Card["Clean Clothes Campaign+Supplier Of"])
      supplier_card.update_attributes! name: widget_cards[:commons_supplier_of]
    end

    widget_cards.each do |codename, cardname|
      Card[cardname]&.update_attributes! codename: codename
    end
  end
end
