# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::CheckPro do
  it_behaves_like "badge card", :check_pro, :silver, 50
end
