# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::InsideSource do
  it_behaves_like "badge card", :inside_source, :bronze, 1
end
