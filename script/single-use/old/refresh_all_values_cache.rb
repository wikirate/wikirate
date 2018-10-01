# -*- encoding : utf-8 -*-

require File.expand_path("../../config/environment",  __FILE__)
require File.expand_path("../wikirate_import_shared", __FILE__)

def find_all_values_caches
  Card.search right: "all_metric_values",
              right_plus: { codename: "solid_cache" }
end

silent_mode do
  find_all_values_caches.each do |card|
    puts "Refreshing #{card.name}'s solid cache".green
    card.update_content_for_cache
  end
end
