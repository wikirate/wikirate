describe Card::Set::Type::MetricValue::BadgeHierarchy do
  describe "#earns_badge" do
    it "returns badge name if threshold is reached" do
      expect(described_class.earns_badge(1, :create, :general))
        .to eq "Researcher"
    end
  end
end
