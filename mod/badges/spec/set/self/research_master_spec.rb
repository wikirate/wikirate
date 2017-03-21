require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ResearchMaster do
  it_behaves_like "badge card", :research_master, :gold, 100
end
