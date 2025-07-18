# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::MetricType::Researched do
  let(:metric) { Card["Jedi+disturbances in the Force"] }

  describe "#metric_type" do
    subject { metric.metric_type }

    it { is_expected.to eq "Researched" }
  end

  describe "#metric_type_codename" do
    subject { metric.metric_type_codename }

    it { is_expected.to eq :researched }
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

    it { is_expected.to eq "disturbances in the Force" }
  end

  describe "#metric_title_card" do
    subject { metric.metric_title_card }

    it { is_expected.to eq Card["disturbances in the Force"] }
  end

  describe "#question_card" do
    subject { metric.question_card.name }

    it { is_expected.to eq "Jedi+disturbances in the Force+Question" }
  end

  describe "#value_type" do
    subject { metric.value_type }

    it { is_expected.to eq "Category" }
  end

  describe "#value_options" do
    subject { metric.value_options }

    it { is_expected.to eq %w[yes no] }
  end

  describe "#categorical?" do
    subject { metric.categorical? }

    it { is_expected.to be_truthy }
  end

  describe "#researched?" do
    subject { metric.researched? }

    it { is_expected.to be_truthy }
  end

  describe "#ten_scale?" do
    subject { metric.ten_scale? }

    it { is_expected.to be_falsey }
  end

  describe "#score?" do
    subject { metric.score? }

    it { is_expected.to be_falsey }
  end

  describe ".create" do
    it "composes the name using the title and designer fields" do
      Card::Auth.as_bot do
        metric = Card.create!(
          type_id: Card::MetricID,
          fields: { title: "MetricTitle1", designer: "MetricDesigner" }
        )
        expect(metric.name).to eq "MetricDesigner+MetricTitle1"
      end
    end
  end

  describe "details tab" do
    it "has metric properties" do
      expect(metric.format.render_details_tab).to(
        have_tag("div.labeled-fields") do
          with_tag "div.RIGHT-topic" do
            with_tag "div.label", text: /Topics/
            with_tag "div.labeled-content", text: /Environment/
          end
          with_tag("div.RIGHT-value_type") do
            with_tag "div.label", text: /Value Type/
            with_tag "div.labeled-content", text: /Category/
          end
        end
      )
    end
  end
end
