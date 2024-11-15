RSpec.describe Card::Set::Abstract::Value do
  before do
    Card["Jedi+deadliness+Death Star+1977+value"].update! content: "50"
  end

  def record_for metric
    Record.where(company_id: "Death Star".card_id,
                 metric_id: metric.card_id,
                 year: 1977).take
  end

  # score of Jedi+deadliness record
  it "updates scores" do
    expect(record_for("Jedi+deadliness+Joe User").value).to eq("5")
  end

  # formula with Jedi+deadliness as a variable metric
  it "updates direct formulas" do
    expect(record_for("Jedi+friendliness").value).to eq("0.02")
  end

  it "updates indirect formulas" do
    expect(record_for("Jedi+darkness rating").value).to eq("7.0")
  end
end
