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

  example "network aware" do
    result = calculate "Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]"
    expect(result[1977][death_star_id]).to eq 90.0
  end

  example "network aware with exist condition" do
    result = calculate "Total[{{Jedi+deadliness|company:Related[Jedi+more evil]}}]"
    expect(result[1977][death_star_id]).to eq 90.0
  end

  example "network aware with count" do
    result = calculate "100*Total[{{always one|company:Related[Commons+Supplied by=Tier 1 Supplier]}}]/{{Commons+Supplied by}}"
    aggregate_failures do
      expect(result[2000][spectre_id]).to eq 50.0
      expect(result[1977][spectre_id]).to eq 100.0
    end
  end
end
