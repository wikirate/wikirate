# -*- encoding : utf-8 -*-

class RenameAboutToGeneralOverview < Card::Migration
  def up
    related_about_cards = Card.search left: {
      type_id: ['in', Card::WikirateCompanyID, Card::WikirateTopicID]
    }, right: 'about'
    related_about_cards.each do |card|
      card.name = "#{card.cardname.left}+General Overview"
      card.save!
    end
  end
end
