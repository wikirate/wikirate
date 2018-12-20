require_relative "../../../support/calculator_stub"

RSpec.describe Formula::Calculator do
  include_context "with calculator stub"

  def calculator formula
    f_card = Card["Jedi+friendliness+formula"]
    f_card.content = formula
    f_card.calculator
  end

  def valid formula
    expect(calculator(formula).validate_formula).to be_empty
  end

  def invalid formula, *errors
    expect(calculator(formula).validate_formula).to eq errors
  end

  example "simple formula" do
    valid "1/{{Jedi+deadliness}}"
  end

  example "invalid method" do
    invalid "NotAMethod[M3]", "unknown or not supported method: NotAMethod"
  end

  example "messed up curly brackets" do
    invalid "2*Total[{{Jedi+deadliness|company: Related[Jedi+more evil]}}}]+{{Jedi+deadliness}}",
            "syntax error: unexpected '}'"
  end

  example "invalid year option" do
    invalid "{{Jedi+deadliness|year: not_a_year}}]",
            "syntax error: unexpected ']'", "invalid year option: not_a_year"
  end

  example "invalid year option list" do
    invalid "2*Total[{{Jedi+deadliness|year: 2001, dog}}]",
            "invalid year option: 2001, dog"
  end

  example "invalid year option rang" do
    invalid "2*Total[{{Jedi+deadliness|year: 2001..}}]",
            "invalid year option: 2001.."
  end

  example "invalid company option" do
    invalid "{{Jedi+deadliness|company: not_a_company}}", "unknown card: not_a_company"
  end

  example "invalid company option list" do
    invalid "{{Jedi+deadliness|company: not_a_card, A}}",
            "unknown card: not_a_card", "not a company:  A"
  end

  example "no company dependency"do
    invalid "{{Jedi+deadliness|company: Death Star}}",
            "there must be at least one nest that doesn't expliciytl specify companies"
  end

  example "company option with invalid relation card" do
    invalid "{{Jedi+deadliness|company: Related[not_a_card]}}",
            "not a metric: \"not_a_card\""
  end

  example "company option with invalid metric" do
      invalid "{{Jedi+deadliness|company: Related[not_a_card]}}",
              "not a metric: \"not_a_card\""
    end

  example "empty company relation condition" do
      invalid "{{Jedi+deadliness|company: Related[Jedi+deadliness]}}",
              "expected a relationship metric: \"Jedi+deadliness\""
  end

  example "company option with invalid relation condition" do
    invalid "{{Jedi+deadliness|company: Related[Jedi+deadliness =]}}",
            "invalid expression \"Jedi+deadliness =\""
  end
end
