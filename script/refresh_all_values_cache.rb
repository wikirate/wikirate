# -*- encoding : utf-8 -*-

require File.expand_path("../../config/environment",  __FILE__)
require File.expand_path("../wikirate_import_shared", __FILE__)

def find_metric_all_values_cached_count
  Card.search left: { type_id: Card::MetricID },
              right: "all_values",
              right_plus: "*cached_count"
end

silent_mode do
  find_metric_all_values_cached_count.each do |card|
    puts "Refreshing #{card.name}'s cached count".green
    card.update_cached_count
  end
end
