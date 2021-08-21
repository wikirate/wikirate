require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Formula::Ruby do
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

  example "network aware" do
    result = calculate "Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]"
    expect(result[1977][death_star_id]).to eq 90.0
  end

  example "network aware with exist condition" do
    result = calculate "Total[{{Jedi+deadliness|company:Related[Jedi+more evil]}}]"
    expect(result[1977][death_star_id]).to eq 90.0
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

  describe "lists" do
    example "simple list" do
      result = calculate "Max[{ {{Joe User+RM}}, {{Jedi+deadliness}} }]"
      expect(result).to include 1977 => { death_star => 100.0 }
    end

    example "simple list without spacing" do
      result = calculate "Max[{{{Joe User+RM}}, {{Jedi+deadliness}}}]"
      expect(result).to include 1977 => { death_star => 100.0 }
    end

    example "list with not_researched option" do
      result = calculate "Zeros[{ {{Joe User+RM }}, "\
                         "{{Joe User+researched number 1| not_researched: 0}} }]"
      expect(result).to include 1977 => { death_star => 0 },
                                2000 => { apple_id => 2 }
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

  example "function names in metrics names M" do
    calculator = described_class.new formula_parser("{{A+Max}}")
    expect { calculator.program }.not_to raise_error
  end
end
