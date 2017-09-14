# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::CompaniesInTheHouse do
  it_behaves_like "badge card", :companies_in_the_house, :gold, 25
end
