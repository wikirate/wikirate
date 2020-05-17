# -*- encoding : utf-8 -*-

class MoreCodenamesForBrandMetric < Card::Migration
  def up
    widget_cards = { commons_has_brands: "Commons+Has Brands",
                     commons_is_brand_of: "Commons+Is Brand Of",
                     ccc_supply_chain_transparency_score: "Clean Clothes Campaign+Supply Chain Transparency Score",
                     ccc_policy_promise_score: "Clean Clothes Campaign+Policy Promise Score",
                     ccc_living_wages_paid_score: "Clean Clothes Campaign+Living Wages Paid Score",
                     ccc_collective_bargaining_agreement: "Clean Clothes Campaign+Collective Bargaining Agreement",
                     ccc_surveyed_workers_who_know_which_brands_they_produce_for: "Clean Clothes Campaign+Surveyed Workers Who Know Which Brands They Produce For",
                     ccc_workers_who_had_pregnancy_leave: "Clean Clothes Campaign+Workers Who Had Pregnancy Leave"
    }

    # add codenames to cards
    widget_cards.each do |codename, cardname|
      ensure_card cardname, codename: codename, type_id: Card::MetricID
    end
    Card::Codename.reset_cache
  end
end
