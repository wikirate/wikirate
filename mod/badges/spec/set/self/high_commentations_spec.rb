# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::HighCommentations do
  it_behaves_like "badge card", :high_commentations, :gold, 250
end
