RSpec.describe Formula::Calculator do
  describe "#formula_for" do
    let(:calculator) { described_class.new(formula) }

    let(:formula) do
      formula = double(Card)
      content_obj =
        Card::Content.new(@formula, Card.new(name: "test"), chunk_list: :formula)
      @chunks = content_obj.find_chunks(Card::Content::Chunk::FormulaInput)
      allow(formula).to receive(:content).and_return @formula
      allow(formula).to receive(:input_cards) do
        @chunks.map(&:referee_card)
      end
      allow(formula).to receive(:input_chunks).and_return @chunks
      allow(formula).to receive(:normalize_value) do |v|
        v
      end
      formula
    end

    example "relative year expression" do
      @nests = ["{{Joe User+researched number 1}}", "{{Joe User+researched number 2| year: -1}}" ]
      @formula = "#{@nests.first}+#{@nests.second}"
      rendered_formula = calculator.formula_for "Samsung", 2015
      expect(rendered_formula).to eq "5+5"
    end

    example "year range" do
      @nests = ["{{Joe User+researched number 1|year: -1..0}}",
                "{{Joe User+researched number 2| year: 2014..2015}}" ]
      @formula = "Sum[#{@nests.first}]+Max[#{@nests.second}]"
      rendered_formula = calculator.formula_for "Samsung", 2015
      expect(rendered_formula).to eq 'Sum[["10", "5"]]+Max[["5", "2"]]'
    end
  end
end
