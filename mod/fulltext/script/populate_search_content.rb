#!/usr/bin/env ruby

require File.expand_path("../../../../config/environment", __FILE__)

Card.find_each do |card|
  card.include_set_modules
  card.update_column :search_content, card.content_for_search
end
