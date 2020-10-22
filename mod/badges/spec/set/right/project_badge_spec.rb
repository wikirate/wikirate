# -*- encoding : utf-8 -*-

describe Card::Set::Right::ProjectBadge do
  it_behaves_like "badge card",
                  "Evil Project+Researcher+project badge", :bronze, 5
  it_behaves_like "badge card",
                  "Evil Project+Research Pro+project badge", :silver, 75
  it_behaves_like "badge card",
                  "Evil Project+Research Master+project badge", :gold, 150
end
