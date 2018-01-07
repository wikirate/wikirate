shared_examples "create badges" do |threshold, badge_name|
  let(:badge_type) { :metric_value }
  let(:badge) { badge_name }

  include_context "award badges context", threshold

  describe "#create count" do
    subject do
      with_user "John" do
        sample_acting_card.create_count
      end
    end

    it { is_expected.to eq threshold }
  end

  describe "badges earned pointer" do
    # it "exists" do
    #   expect(badge_pointer).to be_instance_of Card
    # end
    it "has general badge" do
      expect(user_badges).to include badge
    end
    # it "has designer badge" do
    #   expect(user_badges).to include "Joe User+#{badge}+designer badge"
    # end
    # it "has company badge" do
    #   expect(user_badges).to include "Death_Star+#{badge}+company badge"
    # end
    # it "has project badge" do
    #   expect(user_badges).to include "Evil Project+#{badge}+project badge"
    # end
  end

  def answer number
    year = start_year + number - 1
    "#{metric_card.name}+Death Star+#{year}"
  end

  def value_card number
    Card["#{answer(number)}+value"]
  end

  # reduce thresholds to 1,2,3,...
  def adjust_thresholds
    th_class =
      Card::Set::Type.const_get "#{badge_type.to_s.camelcase}::BadgeSquad"
    [:general, :designer, :company, :project].each do |affinity|
      th_class.change_thresholds(:create, affinity, 1, 2, 3)
    end
  end
end
