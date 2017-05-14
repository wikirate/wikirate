# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::Commentator do
  it_behaves_like "badge card", :commentator, :bronze, 1
end
