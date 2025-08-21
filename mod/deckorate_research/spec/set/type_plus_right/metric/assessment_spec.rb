RSpec.describe Card::Set::TypePlusRight::Metric::Assessment do
  it "updates lookup", as_bot: true do
    metric_card = sample_metric
    metric_card.assessment_card.update! content: "[[Steward Assessed]]"
    expect(metric_card.lookup.policy_id).to eq("Steward Assessed".card_id)
  end
end
