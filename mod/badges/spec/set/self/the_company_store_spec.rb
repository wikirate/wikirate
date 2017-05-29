# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::TheCompanyStore do
  it_behaves_like "badge card", :the_company_store, :silver, 5
end
