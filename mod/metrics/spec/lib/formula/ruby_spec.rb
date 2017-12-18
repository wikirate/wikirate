require_relative "../../support/formula_stub"

describe Formula::Ruby do
  include_context "with formula stub"

  def calculate formula
    described_class.new(formula_card(formula)).result
  end

  it "simple formula" do
    result = calculate "{{Joe User+researched}}*2"
    expect(result[2011]["apple_inc"]).to eq 22.0
    expect(result[2012]["apple_inc"]).to eq 24.0
    expect(result[2013]["apple_inc"]).to eq 26.0
  end

  describe "functions" do
    let(:nest) { "{{Joe User+researched|year:-2..0}}" }

    specify "sum" do
      result = calculate "Sum[#{nest}]"
      expect(result).to include 2012 => { "apple_inc" => 33.0 },
                                2013 => { "apple_inc" => 36.0 }
      expect(result[2011]).to eq({})
    end
    specify "max" do
      result = calculate "Max[#{nest}]"
      expect(result).to include 2012 => { "apple_inc" => 12.0 },
                                2013 => { "apple_inc" => 13.0 }
      expect(result[2011]).to eq({})
    end
    specify "min" do
      result = calculate "Min[#{nest}]"
      expect(result).to include 2012 => { "apple_inc" => 10.0 },
                                2013 => { "apple_inc" => 11.0 }
      expect(result[2011]).to eq({})
    end
    specify "Zeros" do
      result = calculate "Zeros[#{nest}]"
      expect(result).to include 2002 => { "apple_inc" => 1 },
                                2012 => { "apple_inc" => 0 }
    end
    specify "Unknowns" do
      result = calculate "Unknowns[#{nest}]"
      expect(result).to include 2002 => { "apple_inc" => 2 },
                                2012 => { "apple_inc" => 0 }
    end
  end

  describe "formula with yearly variables" do
    it "with fixed year" do
      result = calculate "{{half year|2013}}+{{Joe User+researched}}"
      expect(result).to include 2011 => { "apple_inc" => 1006.5 + 11 },
                                2012 => { "apple_inc" => 1006.5 + 12 },
                                2013 => { "apple_inc" => 1006.5 + 13 }
    end
    it "with relative year" do
      result = calculate "{{half year}}+{{Joe User+researched}}"
      expect(result).to include 2014 => { "apple_inc" => 1007 + 14 },
                                2013 => { "apple_inc" => 1006.5 + 13 }
    end
    it "with sum" do
      result = calculate "Sum[{{half year|2013..0}}]+{{Joe User+researched}}"
      expect(result).to include 2013 => { "apple_inc" => 1006.5 + 13 },
                                2014 => { "apple_inc" => 1007 + 1006.5 + 14 }
      expect(result).not_to include 2012, 2016
    end
    it "double sum" do
      result = calculate "Sum[{{half year|2013..0}}]+Sum[{{Joe User+researched|-1..0}}]"
      expect(result).to include 2013 => { "apple_inc" => 1006.5 + 13 + 12 },
                                2014 => { "apple_inc" => 1007 + 1006.5 + 14 + 13 }
      expect(result).not_to include 2012, 2016
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
