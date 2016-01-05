# -*- encoding : utf-8 -*-

class CorrectVoteCountType < Card::Migration
  def up
    vote_count_cards = Card.search right: '*vote count', type_id: Card::BasicID
    vote_count_cards.each do |card|
      card.update_columns(type_id: Card::NumberID)
    end
  end
end
