#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'

Card::Auth.as_bot

Card.search(:type=>"Claim").each do |card|
  if card.name.length >100

    tags = Card["#{card.name}+tags"]
    if tags 
      if !tags.item_names.include? "name too long"
        puts "Added tag 'name too long' : #{card.name} "
        tags.add_item "name too long"
        tags.save!
      end
    else
      puts "Created tag 'name too long' : #{card.name} "
      new_card = Card.create! :name=>"#{card.name}+tags",:type=>"Pointer"
      new_card.add_item "name too long"
      new_card.save!
    end
  end

end