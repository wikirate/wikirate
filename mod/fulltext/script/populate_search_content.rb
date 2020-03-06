#!/usr/bin/env ruby

require File.expand_path("../../../../config/environment", __FILE__)

Card.find_each do |card|
  card.include_set_modules
  puts "updating #{card.name} to #{card.generate_search_content}"
  card.update_column :search_content, card.generate_search_content
end
