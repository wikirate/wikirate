# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::UncommonCommentator do
  it_behaves_like "badge card", :uncommon_commentator, :silver, 50
end
