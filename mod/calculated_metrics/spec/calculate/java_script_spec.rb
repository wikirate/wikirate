require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Calculate::JavaScript do
  include_context "with calculator stub"
  include_context "with company ids"

  example "simple formula" do
    expect(calculate("{{Joe User+RM}}*2"))
      .to include(have_attributes(year: 2011, company_id: apple, value: 22.0),
                  have_attributes(year: 2012, company_id: apple, value: 24.0),
                  have_attributes(year: 2013, company_id: apple, value: 26.0))
  end

  example "formula with score metric as input" do
    expect(calculate("{{Jedi+disturbances in the Force+Joe User}}*2"))
      .to include(have_attributes(year: 2000, company_id: death_star_id, value: 20.0))
  end
end
