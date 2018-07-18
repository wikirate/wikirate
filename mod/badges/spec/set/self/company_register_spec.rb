# -*- encoding : utf-8 -*-

require_relative "../../support/badges_shared_examples"

describe Card::Set::Self::CompanyRegister do
  it_behaves_like "badge card", :company_register, :bronze, 1
end
