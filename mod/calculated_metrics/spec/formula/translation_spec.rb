require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Formula::Translation do
  include_context "with calculator stub"
  include_context "with company ids"

  example "single category mapping" do
    result = calculate '{"11": "1", "12": "2", "13": "3"}', "Joe User+RM"
    expect(result[2011][apple].value).to eq(1.0)
    expect(result[2012][apple].value).to eq(2.0)
    expect(result[2013][apple].value).to eq(3.0)
  end

  example "multi category mapping" do
    result = calculate '{"1": "10", "2": "20", "13": "3"}', "Joe User+small multi"
    expect(result[2010][sony].value).to eq 30.0
  end

  example "else" do
    result = calculate '{"11": "10", "else": "20"}', "Joe User+RM"
    expect(result[2011][apple].value).to eq(10.0)
    expect(result[2012][apple].value).to eq(20.0)
    expect(result[2013][apple].value).to eq(20.0)
  end

  example "else with multi category" do
    result = calculate '{"1": "10", "else": "20"}', "Joe User+small multi"
    expect(result[2010][sony].value).to eq 30.0
  end
end
