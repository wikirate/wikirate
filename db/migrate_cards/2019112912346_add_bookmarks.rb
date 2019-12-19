# -*- encoding : utf-8 -*-

class AddBookmarks < Card::Migration
  def up
    ensure_code_card "Bookmarks"
    ensure_code_card "Bookmarkers"
    Card.search right: :upvotes do |vote_card|
      vote_card.update! name: Card::Name[vote_card.name.left, :bookmarks]
      vote_card.standardize_items # convert to id pointer
      vote_card.save!

      vote_card.item_cards.each do |markee|
        next unless (marker_search = markee.try(:bookmarkers_card))
        marker_search.update_cached_count
      end
    end
    if Card::Codename.id :voted_up
      Card[:voted_up].update! name: "Bookmarked",
                              codename: "bookmarked",
                              update_referers: true
    end

    if Card::Codename.id :metric_voter
      Card[:metric_voter]&.update! name: "Metric Bookmarker",
                                   codename: "metric_bookmarker",
                                   update_referers: true
    end

    Card.search refer_to: Card::VotedDownID do |vd_ref|
      vd_ref.drop_item! :voted_down
    end
  end
end
