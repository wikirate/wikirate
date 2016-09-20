# -*- encoding : utf-8 -*-

class AllValuesUpdate < Card::Migration
  def up
    import_cards "all_values_update.json"
    delete_code_card :all_values
    remove_old_cache_cards
  end

  def remove_old_cache_cards
    Card.search(left: { right: { codename: ["in", "all_values",
                                            "all_metric_values"] } },
                right: { codename: "cached_count" }).each do |card|
      card.delete
    end
  end
end
