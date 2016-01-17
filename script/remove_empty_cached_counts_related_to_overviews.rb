#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
Card::Auth.current_id = Card::WagnBotID

[Card::WikirateAnalysisID, Card::WikirateTopicID, Card::WikirateCompanyID].each do |type|
  Card.search(
    right: { codename: 'cached_count'},
    content: '0', left: { left: {type_id: type}}, return: 'id') do |card_id|
    puts "~~~\n\nworking on: ~#{card_id}"
    left_id = Card.select(left_id).where(id: card_id).take
    begin
      if (type == Card::WikirateAnalysisID)
        ana_id = Card.select(:left_id).where(id: left_id).take
        Card.where(id: ana_id).update_all trash: true
      end
      Card.where(id: card_id).update_all trash: true
      Card.where(id: left_id).update_all trash: true
    rescue
      puts "FAILED TO DELETE: #{Card.fetch(card_id).name}".red
    end
  end
end

Card.search(right: { codename: 'cached_count'}, content: '0' ).each do |cc|
  puts "~~~\n\nworking: #{ana.name}"
  begin
    cc.update_column :trash, true
  rescue
    puts "FAILED TO DELETE: #{cc.name}"
  end
end

puts "empty trash"
Card.empty_trash

