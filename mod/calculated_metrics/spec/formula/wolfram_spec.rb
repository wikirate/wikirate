require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Formula::Wolfram do
  include_context "with calculator stub"
  include_context "with company ids"

  # it "simple formula" do
  #   result = calculate "{{Joe User+RM}}*2"
  #   expect(result[2011][apple_id]).to eq 22.0
  #   expect(result[2012][apple_id]).to eq 24.0
  #   expect(result[2013][apple_id]).to eq 26.0
  # end
  #
  # describe "functions" do
  #   let(:nest) { "{{Joe User+RM|year:-2..0}}" }
  #
  #   # TODO: test this stuff with less wolfram API calls
  #   #       maybe stub the wolfram api
  #   specify "total" do
  #     result = calculate "Total[#{nest}]"
  #     expect(result).to include 2012 => { apple_id => 33.0 },
  #                               2013 => { apple_id => 36.0 }
  #     expect(result[2011]).to eq({})
  #   end
  #   specify "max" do
  #     result = calculate "Max[#{nest}]"
  #     expect(result).to include 2012 => { apple_id => 12.0 },
  #                               2013 => { apple_id => 13.0 }
  #     expect(result[2011]).to eq({})
  #   end
  #   specify "min" do
  #     result = calculate "Min[#{nest}]"
  #     expect(result).to include 2012 => { apple_id => 10.0 },
  #                               2013 => { apple_id => 11.0 }
  #     expect(result[2011]).to eq({})
  #   end
  #   specify "Zeros" do
  #     Formula::Wolfram::Unknowns::UNKNOWN_STRATEGY = :pass
  #     result = calculate "Zeros[#{nest}]"
  #     expect(result).to include 2002 => { apple_id => 1 },
  #                               2012 => { apple_id => 0 }
  #     Formula::Wolfram::Unknowns::UNKNOWN_STRATEGY = :reject
  #   end
  #   specify "Unknowns" do
  #     result = calculate "Unknowns[#{nest}]"
  #     expect(result).to include 2002 => { apple_id => 2 },
  #                               2012 => { apple_id => 0 }
  #   end
  # end
  #
  # describe "formula with yearly variables" do
  #   it "with fixed year" do
  #     result = calculate "{{half year|2013}}+{{Joe User+RM}}"
  #     expect(result).to include 2011 => { apple_id => 1006.5 + 11 },
  #                               2012 => { apple_id => 1006.5 + 12 },
  #                               2013 => { apple_id => 1006.5 + 13 }
  #   end
  #   it "with relative year" do
  #     result = calculate "{{half year}}+{{Joe User+RM}}"
  #     expect(result).to include 2014 => { apple_id => 1007 + 14 },
  #                               2013 => { apple_id => 1006.5 + 13 }
  #   end
  #   it "with sum" do
  #     result = calculate "Total[{{half year|2013..0}}]+{{Joe User+RM}}"
  #     expect(result).to include 2013 => { apple_id => 1006.5 + 13 },
  #                               2014 => { apple_id => 1007 + 1006.5 + 14 }
  #     expect(result).not_to include 2012, 2016
  #   end
  #   it "double sum" do
  #     result =
  #       calculate "Total[{{half year|2013..0}}]+Total[{{Joe User+RM|-1..0}}]"
  #     expect(result).to include 2013 => { apple_id => 1006.5 + 13 + 12 },
  #                               2014 => { apple_id => 1007 + 1006.5 + 14 + 13 }
  #     expect(result).not_to include 2012, 2016
  #   end
  # end

  # describe ".valid_formula?" do
  #   subject { ::Formula::Ruby.valid_formula? content }
  #
  #   context "with formula with simple symbols" do
  #     let(:content) { "1/{{Jedi+deadliness}}" }
  #
  #     it { is_expected.to be_truthy }
  #   end
  #
  #   context "with formula with several nests and functions" do
  #     let(:content) { "2*Total[{{M1|2000..2010}}]+{{M2}} / Min[{{M3|-1..3}}]" }
  #
  #     it { is_expected.to be_truthy }
  #   end
  # end
end
