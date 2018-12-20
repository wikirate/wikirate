require_relative "../../support/calculator_stub"

RSpec.describe Formula::Translation do
  include_context "with calculator stub"

  def calculate formula
    described_class.new(formula_card(formula)).result
  end

  let(:apple_id) { Card.fetch_id "Apple Inc" }
  let(:spectre_id) { Card.fetch_id "SPECTRE" }
  let(:death_star_id) { Card.fetch_id "Death Star" }

  example "single category mapping" do
    result = calculate '{"1": "10", "2": "20", "3": "30"}'
    expect(result[2011][apple_id]).to eq 22.0
    expect(result[2012][apple_id]).to eq 24.0
    expect(result[2013][apple_id]).to eq 26.0
  end
end
