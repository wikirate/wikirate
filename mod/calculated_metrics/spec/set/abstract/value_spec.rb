RSpec.describe Card::Set::Abstract::Value do
  before do
    Card["Jedi+deadliness+Death Star+1977+value"].update! content: "50"
  end

  def answer_for metric
    Answer.where(company_name: "Death Star", metric_name: metric, year: 1977).take
  end

  # score of Jedi+deadliness answer
  it "updates scores" do
    expect(answer_for("Jedi+deadliness+Joe User").value).to eq("5.0")
  end

  # formula with Jedi+deadliness as a variable metric
  it "updates direct formulas" do
    expect(answer_for("Jedi+friendliness").value).to eq("0.02")
  end

  it "updates indirect formulas" do
    expect(answer_for("Jedi+darkness rating").value).to eq("7.0")
  end
end
