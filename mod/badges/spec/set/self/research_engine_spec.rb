# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ResearchEngine do
  it_behaves_like "badge card", :research_engine, :silver, 50
end
