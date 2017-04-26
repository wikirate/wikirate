# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ASourceOfInspiration do
  it_behaves_like "badge card", :a_source_of_inspiration, :gold, 50
end
