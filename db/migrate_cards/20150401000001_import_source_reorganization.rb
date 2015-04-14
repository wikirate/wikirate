# -*- encoding : utf-8 -*-

class ImportSourceReorganization < Card::Migration
  def up
    # update the type and its codename
    source_card = Card["Source"]
    source_card.type_id = Card::CardtypeID
    source_card.codename = "source"
    source_card.save!
  
    # update webpage type to source
    webpage_wql = { :type_id => Card::WebpageID }
    webpages = Card.search webpage_wql
    webpages.each do |webpage|
      webpage.type_id = Card::SourceID
      webpage.save!
    end
    # default website for source+file
    Card.create :name=>"wikirate.org", :type_id=>Card::WikirateWebsiteID
  end
end

