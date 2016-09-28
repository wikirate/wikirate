# -*- encoding : utf-8 -*-

# - use all_metric_values for both metrics and companies
#   (was all_values for metrics and all_metric_values for companies before)
# - remove deprecated cached_count cards that we used to cache the values
class AllValuesUpdate < Card::Migration
  def up
    import_cards "all_values_update.json"
    delete_code_card :all_values
    remove_old_cache_cards
    ensure_card :all_company, codename: "all_companies", name: "all companies"
  end

  def remove_old_cache_cards
    Card.search(
      left: { right: {
        codename: %w(in all_values all_metric_values all_company all_metrics)
      } },
      right: { codename: "cached_count" }
    ).each(&:delete)
  end
end
