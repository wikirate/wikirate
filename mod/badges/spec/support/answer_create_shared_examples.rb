shared_examples "create badges" do |threshold, badge_name|
  include Card::Model::SaveHelper

  let(:user_badges) do
    Card.fetch("John", badge_type, :badges_earned).item_names
  end
  let(:badge) { badge_name }

  before do
    adjust_thresholds
    create_answer threshold
  end

  describe "#create count" do
    subject do
      as_user "John" do
        value_card(1).create_count
      end
    end
    it { is_expected.to eq threshold }
  end

  describe "user badge pointer" do
    it "exists" do
      expect(Card["John+metric value+badges"]).to be_instance_of Card
    end
    it "has genearal badge" do
      expect(user_badges).to include badge
    end
    it "has designer badge" do
      expect(user_badges).to include "Joe User+#{badge}"
    end
    it "has company badge" do
      expect(user_badges).to include "Death_Star+#{badge}"
    end
    it "has project badge" do
      expect(user_badges).to include "Evil Project+#{badge}"
    end
  end

  def create_answer count=1
    as_user "John" do
      year = START_YEAR
      metric_card.create_values true do
        count.times do |i|
          Death_Star year => i
          year += 1
        end
      end
    end
  end

  def answer number
    year = START_YEAR + number - 1
    "#{METRIC_NAME}+Death Star+#{year}"
  end

  def value_card number
    Card["#{answer(number)}+value"]
  end

  # reduce thresholds to 1,2,3,...
  def adjust_thresholds
    th_class = Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeHierarchy"
    [:general, :designer, :company, :project].each do |affinity|
      th_class.change_thresholds(:create, affinity, 1, 2, 3)
    end
  end
end
