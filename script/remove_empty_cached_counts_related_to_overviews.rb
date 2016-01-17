#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../config/environment'
Card::Auth.current_id = Card::WagnBotID

[Card::WikirateAnalysisID, Card::WikirateTopicID, Card::WikirateCompanyID].each do |type|
  cc_ids = Card.search(
          right: { codename: 'cached_count'},
          content: '0', left: { left: {type_id: type}}, return: 'id'
        )
  left_ids = Card.select(:left_id).where(id: cc_ids).take
  ll_ids = Card.select(:left_id).where(id: left_ids).take



  Card.where(type_id: Card::WikirateAnalysisID, id: ll_ids)
    .update_all trash: true
  Card.where(id: cc_ids).update_all trash: true
  Card.where(id: left_ids).update_all trash: true
end

puts 'handle rest'
ids = Card.search(
        right: { codename: 'cached_count'}, content: '0', return: 'id'
      )
Card.where(id: ids).update_all trash: true

puts "empty trash"
Card.empty_trash
