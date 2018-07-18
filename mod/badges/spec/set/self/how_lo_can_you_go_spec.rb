# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::HowLoCanYouGo do
  it_behaves_like "badge card", :how_lo_can_you_go, :silver, 10
end
