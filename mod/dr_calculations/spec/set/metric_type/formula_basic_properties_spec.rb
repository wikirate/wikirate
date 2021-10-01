# -*- encoding : utf-8 -*-

require_relative "../../../spec/support/formula.rb"

RSpec.describe Card::Set::MetricType::Formula do
  describe "basic properties" do
    before do
      @name = "Jedi+friendliness"
    end

    let(:metric) { Card[@name] }

    describe "#metric_type" do
      subject { metric.metric_type }

      it { is_expected.to eq "Formula" }
    end

    describe "#metric_type_codename" do
      subject { metric.metric_type_codename }

      it { is_expected.to eq :formula }
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

      it { is_expected.to eq "friendliness" }
    end

    describe "#metric_title_card" do
      subject { metric.metric_title_card }

      it { is_expected.to eq Card["friendliness"] }
    end

    describe "#question_card" do
      subject { metric.question_card.name }

      it { is_expected.to eq "Jedi+friendliness+Question" }
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

      it { is_expected.to be_falsey }
    end
  end
end
