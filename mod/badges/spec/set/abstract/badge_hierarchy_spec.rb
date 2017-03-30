describe Card::Set::Abstract::BadgeHierarchy do
  let(:hierarchy) do
    class TestHierarchy
      extend Card::Set::Abstract::BadgeHierarchy
      add_badge_set :create,
                    basic: 10, pointer: 20, phrase: 30,
                    &create_type_count(1)

      add_affinity_badge_set :update,
                             designer: { basic: 10, pointer: 20 },
                             &create_type_count(1)
    end
    TestHierarchy
  end

  describe "map" do
    it "has correct thresholds" do
      expect(hierarchy.map[:create].to_h(:threshold))
    end
    it "has correct affinitiy thresholds" do
      expect(hierarchy.map[:update][:designer].to_h(:threshold))
        .to eq(basic: 10, pointer: 20)
    end
  end

  describe "#all_earned_badges" do
    it "returns all earned badges for simple hierarchy" do
      expect(hierarchy.all_earned_badges(:create, nil, 25))
        .to contain_exactly "Basic", "Pointer"
    end

    it "returns all earned badges for affinity hierarhcy" do
      expect(hierarchy.all_earned_badges(:update, :designer, 20))
        .to contain_exactly "Basic", "Pointer"
    end
  end

  describe "#change_thresholds" do
    it "changes thresholds" do
      hierarchy.change_thresholds :create, nil, 1, 2, 3
      expect(hierarchy.map[:create].to_h(:threshold))
        .to eq(basic: 1, pointer: 2, phrase: 3)
    end

    it "changes affinity thresholds" do
      hierarchy.change_thresholds :update, :designer, 1, 2

      expect(hierarchy.map[:update][:designer].to_h(:threshold))
        .to eq(basic: 1, pointer: 2)
    end
  end
end
