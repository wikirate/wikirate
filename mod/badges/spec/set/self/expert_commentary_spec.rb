# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ExpertCommentary do
  it_behaves_like "badge card", :expert_commentary, :gold, 250
end
