# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

RSpec.describe Card::Set::Self::ACiteToBehold do
  it_behaves_like "badge card", :a_cite_to_behold, :silver, 20
end
