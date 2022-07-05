RSpec.describe Calculate::Calculator do
  let(:metric) { "Jedi+friendliness".card }
  let(:variables) { [{ metric: "Jedi+deadliness", name: "m1" }] }

  def calculator variables, formula
    metric.assign_attributes fields: { variables: variables.to_json, formula: formula }
    metric.calculator
  end

  def valid variables, formula
    expect(calculator(variables, formula).detect_errors).to be_empty
  end

  def invalid variables, formula, *errors
    expect(calculator(variables, formula).detect_errors).to include(*errors)
  end

  example "simple formula" do
    valid variables, "1 / m1"
  end

  example "invalid method" do
    invalid variables, "NotAMethod m1", "ReferenceError: NotAMethod is not defined"
  end

  example "messed up parentheses" do
    invalid variables, "SUM(m1", /SyntaxError: \[stdin\]:\d+:\d+: unmatched OUTDENT/
  end

  example "invalid year option" do
    variables.first[:year] = "not_a_year"
    invalid variables, "m1", "invalid year option: not_a_year"
  end

  example "invalid year option list" do
    variables.first[:year] = "2001, dog"
    invalid variables, "m1", "invalid year option: 2001, dog"
  end

  example "invalid year option range" do
    variables.first[:year] = "2001.."
    invalid variables, "m1", "invalid year option: 2001.."
  end

  example "invalid company option" do
    variables << variables.first.clone
    variables.first[:company] = "not_a_company"
    invalid variables, "m1", /invalid company option: not_a_company/
  end

  example "invalid company option list" do
    variables << variables.first.clone
    variables.first[:company] = "not_a_card, A"
    invalid variables, "m1", /invalid company option: not_a_card, A/
  end

  example "no company dependency" do
    variables.first[:company] = "Death Star"
    invalid variables, "m1",
            "must have at least one variable not explicitly specify company"
  end

  example "company option with company group" do
    variables.first[:company] = "Deadliest"
    invalid variables, "m1",
            "must have at least one variable not explicitly specify company"
  end

  example "company option with relationship metric" do
    variables.first[:company] = "Jedi+more evil"
    valid variables, "m1"
  end
end
