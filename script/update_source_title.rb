#!/usr/bin/env ruby

require File.dirname(__FILE__) + "../../config/environment"

Decko.config.perform_deliveries = false
Card::Auth.as_bot

Card.search(type: Card::SourceID).each do |card|
  cardname = card.name

  next unless Card[cardname + "+link"] && (!Card[cardname + "+title"] || !Card[cardname + "+description"] || !Card[cardname + "+image url"])
  begin
    url = Card[cardname + "+link"].content
    preview = LinkThumbnailer.generate url
    unless Card[cardname + "+image url"]
      unless preview.images.empty?
        Card.create! name: cardname + "+image url", content: preview.images.first.src.to_s
      end
    end
    if !Card[cardname + "+title"] && preview.title
      Card.create! name: cardname + "+title", content: preview.title
    end
    if !Card[cardname + "+description"] && preview.description
      Card.create! name: cardname + "+description", content: preview.description
    end
  rescue
    puts "[[#{cardname}]]:  #{url}"
  end
end
