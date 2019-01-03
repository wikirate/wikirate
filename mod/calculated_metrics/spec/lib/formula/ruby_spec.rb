require_relative "../../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Formula::Ruby do
  include_context "with calculator stub"
  include_context "company ids"

  example "simple formula" do
    result = calculate "{{Joe User+RM}}*2"
    expect(result[2011][apple]).to eq 22.0
    expect(result[2012][apple]).to eq 24.0
    expect(result[2013][apple]).to eq 26.0
  end

  example

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

  describe "functions" do
    let(:nest) { "{{Joe User+RM|year:-2..0}}" }

    specify "Total" do
      result = calculate "Total[#{nest}]"
      expect(result).to include 2012 => { apple_id => 33.0 },
                                2013 => { apple_id => 36.0 }
      expect(result[2011]).to eq({})
    end

    specify "Max" do
      result = calculate "Max[#{nest}]"
      expect(result).to include 2012 => { apple_id => 12.0 },
                                2013 => { apple_id => 13.0 }
      expect(result[2011]).to eq({})
    end

    specify "Min" do
      result = calculate "Min[#{nest}]"
      expect(result).to include 2012 => { apple_id => 10.0 },
                                2013 => { apple_id => 11.0 }
      expect(result[2011]).to eq({})
    end

    specify "Zeros" do
      result = calculate "Zeros[#{nest}]"
      expect(result).to include 2012 => { apple_id => 0 }
    end

    specify "Unknowns" do
      result = calculate "Unknowns[{{Joe User+RM|year:-2..0; unknown: Unknown}}]"
      expect(result).to include 2002 => { apple_id => 2 },
                                2012 => { apple_id => 0 }
    end
  end

  describe "formula with unknown option" do
    specify "Zeros with unknown and year option" do
      result = calculate "Zeros[{{Joe User+RM|year:-2..0; unknown: 0}}]"
           expect(result).to include 2002 => { apple_id => 3 },
                                     2012 => { apple_id => 0 }
    end

    specify "Total with unknown and year option" do
      result = calculate "Total[{{Joe User+RM|year:-2..0; unknown:1}}]"
           expect(result).to include 2002 => { apple_id => 2.0 },
                                     2012 => { apple_id => 33.0 }
    end
  end

  describe "formula with yearly variables" do
    it "with fixed year" do
      result = calculate "{{half year|2013}}+{{Joe User+RM}}"
      expect(result).to include 2011 => { apple_id => 1006.5 + 11 },
                                2012 => { apple_id => 1006.5 + 12 },
                                2013 => { apple_id => 1006.5 + 13 }
    end
    it "with relative year" do
      result = calculate "{{half year}}+{{Joe User+RM}}"
      expect(result).to include 2014 => { apple_id => 1007 + 14 },
                                2013 => { apple_id => 1006.5 + 13 }
    end
    it "with sum" do
      result = calculate "Total[{{half year|2013..0}}]+{{Joe User+RM}}"
      expect(result).to include 2013 => { apple_id => 1006.5 + 13 },
                                2014 => { apple_id => 1007 + 1006.5 + 14 }
      expect(result).not_to include 2012, 2016
    end
    it "double sum" do
      result = calculate "Total[{{half year|year: 2013..0}}]+"\
                         "Total[{{Joe User+RM|year: -1..0}}]"
      expect(result).to include 2013 => { apple_id => 1006.5 + 13 + 12 },
                                2014 => { apple_id => 1007 + 1006.5 + 14 + 13 }
      expect(result).not_to include 2012, 2016
    end
  end
end
