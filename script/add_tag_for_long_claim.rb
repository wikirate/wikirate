#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'

Card::Auth.as_bot

Card.search(:type=>"Claim").each do |card|
  if card.name.length >100
    tags = Card.fetch "#{card.name}+tags", :new=> {:type=>'Pointer'}
    if !tags.item_names.include? "name too long"
      puts "#{tags.new_card? ? "Created" : "Added"} tag 'name too long' : #{card.name} "
      tags.add_item "name too long"
      tags.save!
    end
  end

end