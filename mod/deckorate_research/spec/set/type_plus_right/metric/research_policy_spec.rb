RSpec.describe Card::Set::TypePlusRight::Metric::ResearchPolicy do
  it "updates lookup", as_bot: true do
    metric_card = sample_metric
    metric_card.research_policy_card.update! content: "[[Designer Assessed]]"
    expect(metric_card.lookup.policy_id).to eq("Designer Assessed".card_id)
  end
end
