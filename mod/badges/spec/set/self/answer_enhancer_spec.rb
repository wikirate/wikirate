# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::AnswerEnhancer do
  it_behaves_like "badge card", :answer_enhancer, :silver, 25
end
