describe Card::Set::Type::MetricValue::BadgeHierarchy do
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
              "Researcher", "Research Engine", "Research Fellow",
              "Answer Advancer", "Answer Enhancer", "Answer Romancer",
              "Check Mate", "Checker", "Checksquisite",
              "Commentator", "High Commentations", "Uncommon Commentator"
            )
    end
  end
end
