# -*- encoding : utf-8 -*-

describe Card::Set::Right::CompanyBadge do
  it_behaves_like "badge card",
                  "Death Star+Researcher+company badge", :bronze, 3
  it_behaves_like "badge card",
                  "Death Star+Research Pro+company badge", :silver, 50
  it_behaves_like "badge card",
                  "Death Star+Research Master+company badge", :gold, 100
end
