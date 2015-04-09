# -*- encoding : utf-8 -*-

class ImportSourceReorganization < Card::Migration
  def up
    old_source_card = Card["Source"]
    
    old_source_card_structure = old_source_card.fetch(:trait=>:self).fetch(:trait=>:structure).content
    duplicated_cards = Array.new

    Card.where("trash = 1 and `key` LIKE ?",'source+%').find_each do |c|

      cc = Card.create :name=>c.name,:type=>"Basic"
      if c.name.count("+") == 1
        cc.name = "to_be_deleted_"+cc.name
        duplicated_cards.push cc 
        cc.save!
      end
    end

    duplicated_cards.each do |c|
      c.destroy
    end

    # remove some cards
    source_related_card = Card.search :left=>"Source"
    if source_related_card.any?
      source_related_card.each do |c|
        puts c.name
        if c.name.include?("+Link")
          c.content = "http://notimportant.com"
        end
        c.name = "#{c.name}_to_be_deleted"
        c.save!
        c.destroy
      end
    end
    # remove the old source card
    # remove here not at the top as the recreateion of trash card will recreate the source card too :)
    old_source_card.name = "Source_to_be_deleted"
    old_source_card.save!
    old_source_card.destroy

    # rename webpage to source
    webpage = Card[Card::WebpageID]
    webpage.name = "Source"
    webpage.codename = "source"
    webpage.save!

    Card.create! :name=>"text",:codename=>"text",:type=>"Basic"
    # update itself's structure, do it in import is better

    # webpage_structure = Card.create! :name=>"Source+*self+*structure"
    # webpage_structure.content = old_source_card_structure
    # webpage_structure.save!
    Card.create :name=>"wikirate.org", :type_id=>Card::WikirateWebsiteID
  end
end

