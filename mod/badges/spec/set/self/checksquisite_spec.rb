# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::Checksquisite do
  it_behaves_like "badge card", :checksquisite, :gold, 250
end
