describe Card::Set::Abstract::BadgeHierarchy do
  let(:hierarchy) do
    class TestHierarchy
      extend Card::Set::Abstract::BadgeHierarchy
      hierarchy(
        create: {
          third: 10,
          second: 20,
          first: 30
        }
      )
    end
    TestHierarchy
  end
  describe "#change_thresholds" do
    it "changes thresholds" do
      hierarchy.change_thresholds :create, nil, 1, 2, 3
      expect(hierarchy.map[:create].to_h(:threshold))
        .to eq(third: 1, second: 2, first: 3)
    end
  end
end
