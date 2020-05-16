# -*- encoding : utf-8 -*-

class MoreCodenamesForBrandMetric < Card::Migration
  def up
    widget_cards = { commons_has_brands: "Commons+Has Brands",
                     commons_is_brand_of: "Commons+Is Brand Of",
    }

    # add codenames to cards
    widget_cards.each do |codename, cardname|
      ensure_card cardname, codename: codename, type_id: Card::MetricID
    end
    Card::Codename.reset_cache
  end
end
