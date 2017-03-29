# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::CommentaryTeam do
  it_behaves_like "badge card", :commentary_team, :silver, 50
end
