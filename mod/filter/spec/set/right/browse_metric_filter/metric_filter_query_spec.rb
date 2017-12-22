# -*- encoding : utf-8 -*-

require File.expand_path("../../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::BrowseMetricFilter do
  let(:card) do
    card = Card.new name: "test card"
    card.singleton_class.send :include, described_class
    card
  end

  describe "filter_wql" do
    subject { card.filter_wql_from_params }

    def wql args
      args # .merge type_id: Card::MetricID
    end

    context "name argument" do
      before { filter_args name: "CDP" }
      it { is_expected.to eq(wql(name: %w[match CDP])) }
    end

    context "company argument" do
      before { filter_args wikirate_company: "Apple Inc" }
      it { is_expected.to eq wql(right_plus: "Apple Inc") }
    end

    context "topic argument" do
      before { filter_args wikirate_topic: "myTopic" }
      it do
        is_expected.to eq wql(
          right_plus: [Card::WikirateTopicID, { refer_to: { name: "myTopic" } }]
        )
      end
    end

    context "designer argument" do
      before { filter_args designer: "myDesigner" }
      it do
        is_expected.to eq wql(part: "myDesigner")
      end
    end

    context "metric type" do
      before { filter_args metric_type: "researched" }
      it do
        is_expected.to eq wql(
          right_plus: [Card::MetricTypeID, { refer_to: { name: "researched" } }]
        )
      end
    end

    context "research policy" do
      before { filter_args research_policy: "community assessed" }
      it do
        is_expected.to eq wql(right_plus: [Card::ResearchPolicyID,
                                           { refer_to: { name: "community assessed" } }])
      end
    end

    context "year" do
      before { filter_args year: "2015" }
      it do
        is_expected.to eq wql(
          right_plus: { type_id: Card::WikirateCompanyID,
                        right_plus: "2015" }
        )
      end
    end

    context "project argument" do
      before { filter_args project: "myProject" }
      it do
        is_expected.to eq wql(
          referred_to_by: { left: "myProject", right_id: Card::MetricID }
        )
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "CDP",
                    wikirate_company: "Apple Inc",
                    wikirate_topic: "myTopic",
                    designer: "myDesigner",
                    metric_type: "researched",
                    research_policy: "community assessed",
                    year: "2015",
                    project: "myProject"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq wql(
          name: %w[match CDP],
          and: {
            right_plus: [Card::ResearchPolicyID,
                         { refer_to: { name: "community assessed" } }],
            and: {
              right_plus: [Card::MetricTypeID, { refer_to: { name: "researched"} }],
              and: {
                right_plus: [Card::WikirateTopicID, { refer_to: { name: "myTopic" } }],
                and: {
                  right_plus: "Apple Inc"
                }
              }
            }
          },
          right_plus: { type_id: Card::WikirateCompanyID, right_plus: "2015" },
          part: "myDesigner",
          referred_to_by: { left: "myProject", right_id: Card::MetricID }
        )
      end
    end
  end
end
