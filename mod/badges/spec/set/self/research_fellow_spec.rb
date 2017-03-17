require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ResearchFellow do
  it_behaves_like "badge card", :research_fellow, :gold, 100
end
