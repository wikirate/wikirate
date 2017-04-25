# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::ProjectQA do
  it_behaves_like "badge card", :project_q_a, :bronze, 1
end
