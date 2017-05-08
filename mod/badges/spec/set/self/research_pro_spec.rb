# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ResearchPro do
  it_behaves_like "badge card", :research_pro, :silver, 50
end
