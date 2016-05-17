#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../config/environment"
Card::Auth.current_id = Card::WagnBotID

wql = {
  type_id: Card::WikirateCompanyID,
  referred_to_by:
    "Rating_Companies_on_Responsible_Sourcing_Data_Sprint+companies"
}

Card.search(wql) do |company|
  puts "checking #{company.name}"
  analname = "#{company.name}+missing analyses"
  Card.fetch(analname).item_cards(limit: 1000).each do |topic|
    puts "....updating #{topic.name}"
    analysis = Card.fetch company, topic,
                          new: { type_id: Card::WikirateAnalysisID }
    analysis.save! if analysis.new_card?
    [:claim, :metric, :source].each do |attrib|
      attrib_card = analysis.fetch trait: attrib
      next unless attrib_card.count > 0
      begin
        attrib_card.update_cached_count
      rescue
        puts "#{analysis.name} failed on #{attrib}"
      end
    end
  end
end
