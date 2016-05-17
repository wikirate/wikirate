describe Formula::Ruby do
  let(:formula) do
    formula = double(Card)
    content_obj =
      Card::Content.new(@formula, Card.new(name:"test"), chunk_list: :formula)
    @chunks = content_obj.find_chunks(Card::Content::Chunk::FormulaInput)
    allow(formula).to receive(:content).and_return @formula
    allow(formula).to receive(:input_cards) do
      @chunks.map do |chunk|
        chunk.referee_card
      end
    end
    allow(formula).to receive(:input_chunks).and_return @chunks
    allow(formula).to receive(:normalize_value) do |v|
      v
    end
    formula
  end
  subject { Formula::Ruby.new(formula).result }
  it "simple formula" do
    @nests = ["{{Joe User+researched}}"]
    @formula = "#{@nests.first}*2"
    expect(subject[2011]["apple_inc"]).to eq 22.0
    expect(subject[2012]["apple_inc"]).to eq 24.0
    expect(subject[2013]["apple_inc"]).to eq 26.0
  end
  describe "functions" do
    before do
      @nest = "{{Joe User+researched|year:-2..0}}"
    end
    it "sum" do
      @formula = "Sum[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]["apple_inc"]).to eq 33.0
      expect(subject[2013]["apple_inc"]).to eq 36.0
    end
    it "max" do
      @formula = "Max[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]["apple_inc"]).to eq 12.0
      expect(subject[2013]["apple_inc"]).to eq 13.0
    end
    it "min" do
      @formula = "Min[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]["apple_inc"]).to eq 10.0
      expect(subject[2013]["apple_inc"]).to eq 11.0
    end
  end

  describe "formula with yearly variables" do
    it "with fixed year" do
      @formula = "{{half year|2013}}+{{Joe User+researched}}"
      expect(subject[2011]["apple_inc"]).to eq 1006.5+11
      expect(subject[2012]["apple_inc"]).to eq 1006.5+12
      expect(subject[2013]["apple_inc"]).to eq 1006.5+13
    end
    it "with relative year" do
      @formula = "{{half year}}+{{Joe User+researched}}"
      expect(subject[2014]["apple_inc"]).to eq 1007+14
      expect(subject[2013]["apple_inc"]).to eq 1006.5+13
    end
    it "with sum" do
      @formula = "Sum[{{half year|2013..0}}]+{{Joe User+researched}}"
      expect(subject[2012]["apple_inc"]).to eq nil
      expect(subject[2013]["apple_inc"]).to eq 1006.5 + 13
      expect(subject[2014]["apple_inc"]).to eq 1007 + 1006.5 + 14
      expect(subject[2016]["apple_inc"]).to eq nil
    end
    it "double sum" do
      @formula = "Sum[{{half year|2013..0}}]+Sum[{{Joe User+researched|-1..0}}]"
      expect(subject[2012]["apple_inc"]).to eq nil
      expect(subject[2013]["apple_inc"]).to eq 1006.5 + 13 + 12
      expect(subject[2014]["apple_inc"]).to eq 1007 + 1006.5 + 14 + 13
      expect(subject[2016]["apple_inc"]).to eq nil
    end
  end

  describe ".valid_formula?" do
    subject { ::Formula::Ruby.valid_formula? content }
    context "for formula with simple symbols" do
      let(:content) { "1/{{Jedi+deadliness}}" }
      it { is_expected.to be_truthy }
    end
    context "for formula with several nests and functions" do
      let(:content) { "2*Sum[{{M1|2000..2010}}]+{{M2}} / Min[{{M3|-1..3}}]" }
      it { is_expected.to be_truthy }
    end
  end
end
