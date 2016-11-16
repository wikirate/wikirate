# -*- encoding : utf-8 -*-

class ChangeDeletePermissionsForCounts < Card::Migration
  def up
    counts = [:vote_count, :downvote_count, :upvote_count, :contribution_count,
              :direct_contribution_count, :source_type]
    counts.each do |codename|
      create_or_update name: "#{Card[codename].name}+*right+*delete",
                       content: "_left",
                       type_id: Card::PointerID
    end
  end
end
