#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"

Card::Auth.as_bot

Card.search(type_id: Card::ClaimID).each do |card|
  # claim name should not be longer than 100 characters
  next unless card.name.length > 100
  tags = card.fetch trait: "wikirate_tag", new: { type: "Pointer" }
  next if tags.item_names.include? "name too long"
  action = tags.new_card? ? "Created" : "Added"
  puts "#{action} tag 'name too long' : #{card.name} "
  tags.add_item "name too long"
  tags.save!
end
