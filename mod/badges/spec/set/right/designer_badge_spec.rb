# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Right::DesignerBadge do
  it_behaves_like "badge card",
                  "Jedi+Researcher+designer badge", :bronze, 10
  it_behaves_like "badge card",
                  "Jedi+Research Engine+designer badge", :silver, 100
  it_behaves_like "badge card",
                  "Jedi+Research Fellow+designer badge", :gold, 250
end
