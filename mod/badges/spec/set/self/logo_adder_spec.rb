# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::LogoAdder do
  it_behaves_like "badge card", :logo_adder, :bronze, 1
end
