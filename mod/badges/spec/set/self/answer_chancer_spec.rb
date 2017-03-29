# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::AnswerChancer do
  it_behaves_like "badge card", :answer_chancer, :bronze, 1
end
