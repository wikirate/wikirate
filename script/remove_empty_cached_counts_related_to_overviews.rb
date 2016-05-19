#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.current_id = Card::WagnBotID

[Card::WikirateAnalysisID, Card::WikirateTopicID,
 Card::WikirateCompanyID].each do |type|
  puts "clean cached counts for cardtype id #{type}"
  cc_ids = Card.search right: { codename: "cached_count" },
                       content: "0", left: { left: { type_id: type } },
                       return: "id"
  left_ids = Card.where(id: cc_ids).pluck(:left_id)
  ll_ids = Card.where(id: left_ids).pluck(:left_id)

  Card.where(type_id: Card::WikirateAnalysisID, id: ll_ids)
      .update_all trash: true
  Card.where(id: cc_ids).update_all trash: true
  Card.where(id: left_ids).update_all trash: true
end

puts "clean cached counts with virtual left"
ids = Card.search right: { codename: "cached_count" }, content: "0",
                  return: "id"
Card.where(id: ids).update_all trash: true

puts "empty trash"
Card.empty_trash
