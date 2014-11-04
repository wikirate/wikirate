# -*- encoding : utf-8 -*-

class AddCreatorUpvotes < Wagn::Migration
  def up
    Card.search(:type_id => Card::ClaimID).each do |claim|

      if claim.creator.id != Card::WagnBotID   and 
         !claim.creator.upvotes_card.include_item? "~#{claim.id}" and 
         !claim.creator.downvotes_card.include_item? "~#{claim.id}"
         
        up_card = claim.creator.upvotes_card
        up_card.add_id claim.id
        up_card.save!
        vc = claim.vote_count_card
        vc.update_votecount
        vc.save!
      end
    end
  end
end
