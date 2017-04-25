# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::LogoAndBehold do
  it_behaves_like "badge card", :logo_and_behold, :gold, 100
end
