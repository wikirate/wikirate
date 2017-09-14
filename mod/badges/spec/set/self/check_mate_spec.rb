# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::CheckMate do
  it_behaves_like "badge card", :check_mate, :gold, 250
end
