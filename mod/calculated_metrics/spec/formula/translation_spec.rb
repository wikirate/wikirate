require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Calculate::Translation do
  include_context "with calculator stub"
  include_context "with company ids"

  example "single category mapping" do
    expect(calculate('{"11": "1", "12": "2", "13": "3"}', "Joe User+RM"))
      .to include(have_attributes(year: 2011, company_id: apple, value: 1.0),
                  have_attributes(year: 2012, company_id: apple, value: 2.0),
                  have_attributes(year: 2013, company_id: apple, value: 3.0))
  end

  example "multi category mapping" do
    expect(calculate('{"1": "10", "2": "20", "13": "3"}', "Joe User+small multi"))
      .to include(have_attributes(year: 2010, company_id: sony, value: 30.0))
  end

  example "else" do
    expect(calculate('{"11": "10", "else": "20"}', "Joe User+RM"))
      .to include(have_attributes(year: 2011, company_id: apple, value: 10.0),
                  have_attributes(year: 2012, company_id: apple, value: 20.0),
                  have_attributes(year: 2013, company_id: apple, value: 20.0))
  end

  example "else with multi category" do
    expect(calculate('{"1": "10", "else": "20"}', "Joe User+small multi"))
      .to include(have_attributes(year: 2010, company_id: sony, value: 30.0))
  end
end
