shared_examples "create badges" do |threshold, badge_name|
  include Card::Model::SaveHelper

  let(:user_badges) do
    Card["John+badges"].item_names
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
    th_class = described_class::Thresholds
    new_map =
      th_class.map[:create].each_with_object({}) do |(k, th), hash|
        hash[k] = th.values.map.with_index do |name, index|
          [index + 1, name]
        end.to_h
      end
    th_class.change_thresholds(:create, new_map)
  end

  before do
    adjust_thresholds
    create_answer threshold
  end

  let(:badge) { badge_name }
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
end


shared_examples "badge card" do |name, level, threshold|
  let(:card) { Card.fetch name }
  describe "#threshold" do
    subject { card.threshold }
    it { is_expected.to eq threshold }
  end

  describe "#badge_level" do
    subject { card.badge_level }
    it { is_expected.to eq level }
  end

  context "html format" do
    describe "view :level" do
      subject { render_view :level, name: name }
      it "has glyphicon" do
        is_expected.to have_tag "span.glyphicon-certificate"
      end

      it "has correct level class" do
        is_expected.to have_tag "span.glyphicon-certificate.#{level}"
      end
    end
  end
end
