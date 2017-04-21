# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::AnswerAdvancer do
  it_behaves_like "badge card", :answer_advancer, :gold, 100
end
