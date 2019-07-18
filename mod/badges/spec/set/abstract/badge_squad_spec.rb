describe Card::Set::Abstract::BadgeSquad do
  let(:squad) do
    # a badge squad for testing
    class TestSquad
      extend Card::Set::Abstract::BadgeSquad
      add_badge_line :create,
                     basic: 10, pointer: 20, phrase: 30,
                     &create_type_count(1)

      add_affinity_badge_line :update,
                              designer: { basic: 10, pointer: 20 },
                              &create_type_count(1)
    end
    TestSquad
  end

  describe "map" do
    it "has correct thresholds" do
      expect(squad.map[:create].to_h(:threshold))
    end
    it "has correct affinitiy thresholds" do
      expect(squad.map[:update][:designer].to_h(:threshold))
        .to eq(basic: 10, pointer: 20)
    end
  end

  describe "#all_earned_badges" do
    it "returns all earned badges for simple squad" do
      expect(squad.all_earned_badges(:create, nil, 25))
        .to contain_exactly "RichText", "Pointer"
    end

    it "returns all earned badges for affinity squad" do
      expect(squad.all_earned_badges(:update, :designer, 20))
        .to contain_exactly "RichText", "Pointer"
    end
  end

  describe "#change_thresholds" do
    it "changes thresholds" do
      squad.change_thresholds :create, nil, 1, 2, 3
      expect(squad.map[:create].to_h(:threshold))
        .to eq(basic: 1, pointer: 2, phrase: 3)
    end

    it "changes affinity thresholds" do
      squad.change_thresholds :update, :designer, 1, 2

      expect(squad.map[:update][:designer].to_h(:threshold))
        .to eq(basic: 1, pointer: 2)
    end
  end
end
