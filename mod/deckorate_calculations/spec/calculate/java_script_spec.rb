require_relative "../support/calculator_stub"

RSpec.describe Calculate::JavaScript do
  include_context "with calculator stub"
  include_context "with company ids"

  example "simple formula" do
    expect(calculate("m1 * 2", "Joe User+RM"))
      .to include(have_attributes(year: 2011, company_id: apple, value: 22.0),
                  have_attributes(year: 2012, company_id: apple, value: 24.0),
                  have_attributes(year: 2013, company_id: apple, value: 26.0))
  end

  example "formula with score metric as input" do
    expect(calculate("m1 * 2", "Jedi+disturbances in the Force+Joe User"))
      .to include(have_attributes(year: 2000, company_id: death_star_id, value: 20.0))
  end

  example "formula handling unknowns" do
    formula = <<~FORMULA.strip_heredoc
      throw new Error("formula run on unknown value!") if m2 == undefined
      m1 + m2
    FORMULA
    calc = calculator(formula,
                      { metric: "Joe User+RM", name: "m1" },
                      { metric: "Jedi+know the unknowns", name: "m2" })

    expect(calc.result.map(&:value)).to include("Unknown")
    expect(calc.detect_errors).to be_empty
  end

  example "formula with explicit unknowns" do
    formula = <<~FORMULA.strip_heredoc
      researched = [m1, m2].filter (val) ->  val != "-1"
      numKnown(researched) / researched.length * 100
    FORMULA

    expect(calculate(formula,
                     { metric: "Jedi+know the unknowns", name: "m1", unknown: "Unknown" },
                     { metric: "Joe User+RM", name: "m2", unknown: "Unknown" }))
      .to include(have_attributes(year: 2001, company_id: apple, value: 50.0))
  end
end
