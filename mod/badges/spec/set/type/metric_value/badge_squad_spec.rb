describe Card::Set::Type::MetricValue::BadgeSquad do
  describe "#earns_badge" do
    it "returns badge name if threshold is reached" do
      expect(described_class.earns_badge(:create, :general, 1))
        .to eq "Researcher"
    end
  end

  describe "#badge_names" do
    it "returns all non-affinity badge names" do
      expect(described_class.badge_names)
        .to contain_exactly(
          "Researcher", "Research Pro", "Research Master",
          "Answer Advancer", "Answer Enhancer", "Answer Chancer",
          "Checker", "Check Pro", "Check Mate",
          "Commentator", "Commentary Team", "Expert Commentary"
        )
    end
  end
end
