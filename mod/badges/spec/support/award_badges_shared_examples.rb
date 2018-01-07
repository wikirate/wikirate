RSpec.shared_context "award badges context" do |threshold|
  include Card::Model::SaveHelper

  let(:badge_pointer) { Card.fetch("John", badge_type, :badges_earned) }
  let(:user_badges) { badge_pointer.item_names }

  before do
    adjust_thresholds
    trigger_awarded_action threshold
  end

  def trigger_awarded_action count=1
    with_user "John" do
      count.times do |i|
        binding.pry
        execute_awarded_action i + 1
      end
    end
  end

  # reduce thresholds to 1,2,3
  def adjust_thresholds
    th_class =
      Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeSquad"
    th_class.change_thresholds(badge_action, nil, 1, 2, 3)
  end
end

RSpec.shared_examples "award badges" do |threshold, badge_name|
  let(:badge) { badge_name }

  include_context "award badges context", threshold

  describe "#count" do
    subject do
      with_user "John" do
        sample_acting_card.badge_squad.count(badge_action)
      end
    end

    it { is_expected.to eq threshold }
  end

  describe "'+badges_earned' pointer" do
    it "exists" do
      expect(badge_pointer).to be_instance_of Card
    end
    it "has badge" do
      expect(user_badges).to include badge
    end
  end

  def badge_action_card number
    acting_card number
  end
end
