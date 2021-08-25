require_relative "../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Calculate::Ruby do
  include_context "with calculator stub"
  include_context "with company ids"

  example "simple formula" do
    expect(calculate("{{Joe User+RM}}*2"))
      .to include(have_attributes(year: 2011, company_id: apple, value: 22.0),
                  have_attributes(year: 2012, company_id: apple, value: 24.0),
                  have_attributes(year: 2013, company_id: apple, value: 26.0))
  end

  example "formula with score metric as input" do
    expect(calculate("{{Jedi+disturbances in the Force+Joe User}}*2"))
      .to include(have_attributes(year: 2000, company_id: death_star_id, value: 20.0))
  end

  example "network aware" do
    expect(calculate("Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]"))
      .to include(have_attributes(year: 1977, company_id: death_star_id, value: 90.0))
  end

  example "network aware with exist condition" do
    expect(calculate("Total[{{Jedi+deadliness|company:Related[Jedi+more evil]}}]"))
      .to include(have_attributes(year: 1977, company_id: death_star_id, value: 90.0))
  end

  describe "functions" do
    let(:nest) { "{{Joe User+RM|year:-2..0}}" }

    specify "Total" do
      expect(calculate("Total[#{nest}]"))
        .to include(have_attributes(year: 2012, company_id: apple_id, value: 33.0),
                    have_attributes(year: 2013, company_id: apple_id, value: 36.0))
    end

    specify "Max" do
      expect(calculate("Max[#{nest}]"))
        .to include(have_attributes(year: 2012, company_id: apple_id, value: 12.0),
                    have_attributes(year: 2013, company_id: apple_id, value: 13.0))
    end

    specify "Min" do
      expect(calculate("Min[#{nest}]"))
        .to include(have_attributes(year: 2012, company_id: apple_id, value: 10.0),
                    have_attributes(year: 2013, company_id: apple_id, value: 11.0))
    end

    specify "Zeros" do
      expect(calculate("Zeros[#{nest}]"))
        .to include(have_attributes(year: 2012, company_id: apple_id, value: 0))
    end

    specify "Unknowns" do
      expect(calculate("Unknowns[{{Joe User+RM|year:-2..0; unknown: Unknown}}]"))
        .to include(have_attributes(year: 2002, company_id: apple_id, value: 2),
                    have_attributes(year: 2012, company_id: apple_id, value: 0))
    end
  end

  describe "lists" do
    example "simple list" do
      expect(calculate("Max[{ {{Joe User+RM}}, {{Jedi+deadliness}} }]"))
        .to include(have_attributes(year: 1977, company_id: death_star_id, value: 100.0))
    end

    example "simple list without spacing" do
      expect(calculate("Max[{{{Joe User+RM}}, {{Jedi+deadliness}}}]"))
        .to include(have_attributes(year: 1977, company_id: death_star_id, value: 100.0))
    end

    example "list with not_researched option" do
      expect(calculate("Zeros[{ {{Joe User+RM }}, "\
                       "{{Joe User+researched number 1| not_researched: 0}} }]"))
        .to include(have_attributes(year: 1977, company_id: death_star, value: 0),
                    have_attributes(year: 2000, company_id: apple_id, value: 2))
    end
  end

  describe "formula with unknown option" do
    specify "Zeros with unknown and year option" do
      expect(calculate("Zeros[{{Joe User+RM|year:-2..0; unknown: 0}}]"))
        .to include(have_attributes(year: 2002, company_id: apple_id, value: 3),
                    have_attributes(year: 2012, company_id: apple_id, value: 0))
    end

    specify "Total with unknown and year option" do
      expect(calculate("Total[{{Joe User+RM|year:-2..0; unknown:1}}]"))
        .to include(have_attributes(year: 2002, company_id: apple_id, value: 2.0),
                    have_attributes(year: 2012, company_id: apple_id, value: 33.0))
    end
  end

  example "function names in metrics names M" do
    calculator = described_class.new formula_parser("{{A+Max}}")
    expect { calculator.program }.not_to raise_error
  end
end
