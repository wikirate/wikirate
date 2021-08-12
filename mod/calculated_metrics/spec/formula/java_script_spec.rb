require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Formula::JavaScript do
  include_context "with calculator stub"
  include_context "with company ids"

  example "simple formula" do
    result = calculate "{{Joe User+RM}}*2"
    expect(result[2011][apple]).to eq 22.0
    expect(result[2012][apple]).to eq 24.0
    expect(result[2013][apple]).to eq 26.0
  end

  example "formula with score metric as input" do
    result = calculate "{{Jedi+disturbances in the Force+Joe User}}*2"
    expect(result[2000][death_star_id]).to eq 20.0
  end


end
