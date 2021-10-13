# -*- encoding : utf-8 -*-

# the metric in the test database:
# Card::Metric.create name: 'Jedi+deadliness+Joe User',
#                     type: :score,
#                     formula: '{{Jedi+deadliness}}/10'
RSpec.describe Card::Set::MetricType::Score, "basic properties" do
  let(:metric) { Card[@name] }

  before { @name = "Jedi+deadliness+Joe User" }

  describe "score card" do
    let(:score_card) { Card[:score] }

    it { is_expected.to be_truthy }
    it "has codename" do
      expect(score_card.codename).to eq :score
    end
    it 'has type "metric type"' do
      expect(score_card.type_id).to eq Card["metric type"].id
    end
  end

  describe "#metric_type" do
    subject { metric.metric_type }

    it { is_expected.to eq "Score" }
  end

  describe "#metric_type_codename" do
    subject { metric.metric_type_codename }

    it { is_expected.to eq :score }
  end

  describe "#metric_designer" do
    subject { metric.metric_designer }

    it { is_expected.to eq "Jedi" }
  end

  describe "#metric_designer_card" do
    subject { metric.metric_designer_card }

    it { is_expected.to eq Card["Jedi"] }
  end

  describe "#metric_title" do
    subject { metric.metric_title }

    it { is_expected.to eq "deadliness" }
  end

  describe "#metric_title_card" do
    subject { metric.metric_title_card }

    it { is_expected.to eq Card["deadliness"] }
  end

  describe "#question_card" do
    subject { metric.question_card.name }

    it { is_expected.to eq "Jedi+deadliness+Joe User+Question" }
  end

  describe "#value_type" do
    subject { metric.value_type }

    it { is_expected.to eq "Number" }
  end

  describe "#categorical?" do
    subject { metric.categorical? }

    it { is_expected.to be_falsey }
  end

  describe "#researched?" do
    subject { metric.researched? }

    it { is_expected.to be_falsey }
  end

  describe "#score?" do
    subject { metric.score? }

    it { is_expected.to be_truthy }
  end

  describe "#scorer" do
    subject { metric.scorer }

    it { is_expected.to eq "Joe User" }
  end

  describe "#scorer_card" do
    subject { metric.scorer_card }

    it { is_expected.to eq Card["Joe User"] }
  end

  describe "#basic_metric" do
    subject { metric.basic_metric }

    it { is_expected.to eq "Jedi+deadliness" }
  end
end
