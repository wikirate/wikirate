# -*- encoding : utf-8 -*-

class AddCreatorUpvotes < Card::Migration
  def up
    Card.search(type_id: [:in, Card::ClaimID, Card::WebpageID], return: :name).each do |name|
      begin
        subject = Card[name]
        if subject.creator.id != Card::WagnBotID &&
           !subject.creator.upvotes_card.include_item?("~#{subject.id}") &&
           !subject.creator.downvotes_card.include_item?("~#{subject.id}")

          up_card = subject.creator.upvotes_card
          up_card.add_id subject.id
          up_card.save!
          vc = subject.vote_count_card
          vc.update_votecount
          vc.save!
        end
      rescue => e
        puts "Error migrating votes for #{subject.name} : #{e.message}"
      end
    end
  end
end
