# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::AnswerRomancer do
  it_behaves_like "badge card", :answer_romancer, :gold, 100
end
