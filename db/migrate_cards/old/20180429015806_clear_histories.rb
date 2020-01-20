# -*- encoding : utf-8 -*-

class ClearHistories < Card::Migration
  def up
    %i[vote_count upvote_count downvote_count upvotes downvotes badges_earned
       solid_cache token autoname machine_input machine_output].each do |codename|
      Card.search right_id: Card::Codename.id(codename) do |card|
        card.clear_history
      end
    end
  end
end
