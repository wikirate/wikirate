# -*- encoding : utf-8 -*-

class AddCodenamesForBrandMetric < Card::Migration
  def up
    widget_cards = { oc_has_brands: "Open Corporates+Has Brands",
                     oc_is_brand_of: "Open Corporates+Is Brand Of",
                     ccc_address: "Clean Clothes Campaign+Address",
                     ccc_number_of_workers: "Clean Clothes Campaign+Number of Workers",
                     ccc_female_workers: "Clean Clothes Campaign+Female Workers",
                     ccc_male_workers: "Clean Clothes Campaign+male Workers",
                     core_headquarters_location: "Core+Headquarters Location",
                     commons_supplied_by: "Commons+Supplied by"
    }

    # add codenames to cards
    widget_cards.each do |codename, cardname|
      ensure_card cardname, codename: codename, type_id: Card::MetricID
    end
    Card::Codename.reset_cache
  end
end
