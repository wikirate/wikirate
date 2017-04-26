# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::Checker do
  it_behaves_like "badge card", :checker, :bronze, 1
end
