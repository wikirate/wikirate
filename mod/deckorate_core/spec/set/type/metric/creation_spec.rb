RSpec.describe Card::Set::Type::Metric::Creation do
  def card_subject
    Card.new type: :metric
  end

  # check_views_for_errors

  def create_metric_with_policy research_policy
    Card.create! type: :metric, name: "Joe User+test metric",
                 fields: {
                   metric_type: :researched.cardname,
                   value_type: "Number",
                   research_policy: research_policy
                 }
  end

  context "when Steward Assessed" do
    it "can be deleted by creator" do
      expect { create_metric_with_policy("Steward Assessed").delete! }.not_to raise_error
    end
  end

  context "when Community Assessed" do
    xit "cannot be deleted by creator" do
      expect { create_metric_with_policy("Community Assessed").delete! }.to raise_error
    end
  end
end
