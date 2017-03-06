# -*- encoding : utf-8 -*-
require_relative "../../support/badges_shared_examples"

describe Card::Set::Right::CompanyBadge do
  it_behaves_like "badge card",
                  "Death Star+Researcher+company badge", :bronze, 3
  it_behaves_like "badge card",
                  "Death Star+Research Engine+company badge", :silver, 50
  it_behaves_like "badge card",
                  "Death Star+Research Fellow+company badge", :gold, 100
end
