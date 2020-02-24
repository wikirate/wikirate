# -*- encoding : utf-8 -*-

require File.expand_path("../../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseMetricFilter do
  describe "filter_wql" do
    subject { card_subject.filter_wql_from_params }

    context "name argument" do
      before { filter_args name: "CDP" }
      it { is_expected.to eq(name: %w[match CDP]) }
    end

    context "topic argument" do
      before { filter_args wikirate_topic: "myTopic" }
      it { is_expected.to eq(topic_wql) }
    end

    def topic_wql
      simple_field_filter Card::WikirateTopicID, "myTopic"
    end

    def simple_field_filter field_id, value
      { right_plus: [field_id, { refer_to: value }] }
    end

    context "designer argument" do
      before { filter_args designer: "myDesigner" }
      it { is_expected.to eq(part: "myDesigner") }
    end

    context "metric type" do
      before { filter_args metric_type: "researched" }
      it { is_expected.to eq(metric_type_wql) }
    end

    def metric_type_wql
      simple_field_filter Card::MetricTypeID, "researched"
    end

    context "value type" do
      before { filter_args value_type: "Category" }
      it { is_expected.to eq(value_type_wql) }
    end

    def value_type_wql
      simple_field_filter Card::ValueTypeID, "Category"
    end

    context "research policy" do
      before { filter_args research_policy: "community assessed" }
      it { is_expected.to eq(policy_wql) }
    end

    def policy_wql
      simple_field_filter Card::ResearchPolicyID, "community assessed"
    end

    context "year" do
      before { filter_args year: "2015" }
      it do
        is_expected.to eq(right_plus: { type_id: Card::WikirateCompanyID,
                                        right_plus: "2015" })
      end
    end

    context "project argument" do
      before { filter_args project: "myProject" }
      it do
        is_expected.to eq(referred_to_by: { left: "myProject",
                                            right_id: Card::MetricID })
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "CDP",
                    wikirate_topic: "myTopic",
                    designer: "myDesigner",
                    metric_type: "researched",
                    research_policy: "community assessed",
                    year: "2015",
                    project: "myProject"
      end

      it "joins filter conditions correctly" do
        is_expected.to eq(
          name: %w[match CDP],
          and: policy_wql.merge(
            and: metric_type_wql.merge(
              and: topic_wql
            )
          ),
          right_plus: { type_id: Card::WikirateCompanyID, right_plus: "2015" },
          part: "myDesigner",
          referred_to_by: { left: "myProject", right_id: Card::MetricID }
        )
      end
    end
  end
end
