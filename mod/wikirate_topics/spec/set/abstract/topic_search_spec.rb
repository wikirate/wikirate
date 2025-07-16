# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::TopicSearch do
  include FilterSpecHelper

  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql_from_params }

    def cql args
      args # merge type_id: Card::TopicID
    end

    context "with name argument" do
      before { filter_args name: "Animal Rights" }
      it { is_expected.to eq cql(name: ["match", "Animal Rights"]) }
    end

    context "with framewok argument" do
      before { filter_args topic_framework: "Star Wars Topics" }
      it do
        is_expected
          .to eq(cql(right_plus: [:topic_framework.card_id,
                                  { refer_to: "Star Wars Topics" }]))
      end
    end

    # context "with company argument" do
    #   before { filter_args company: "Apple Inc" }
    #   it { is_expected.to eq cql(found_by: "Apple Inc+topic") }
    # end
    #
    # context "with metric argument" do
    #   before { filter_args metric: "myMetric" }
    #   it do
    #     is_expected.to eq cql(
    #       referred_to_by: { left: { name: "myMetric" }, right: "topic" }
    #     )
    #   end
    # end
    #
    # context "with dataset argument" do
    #   before { filter_args dataset: "myDataset" }
    #   it do
    #     is_expected.to eq cql(
    #       referred_to_by: { left: { name: "myDataset" }, right: "topic" }
    #     )
    #   end
    # end
    #
    # context "with multiple filter conditions" do
    #   before do
    #     filter_args name: "Animal Rights",
    #                 company: "Apple Inc",
    #                 metric: "myMetric",
    #                 dataset: "myDataset"
    #   end
    #   it "joins filter conditions correctly" do
    #     is_expected.to eq cql(
    #       name: ["match", "Animal Rights"],
    #       found_by: "Apple Inc+topic",
    #       referred_to_by: [
    #         { left: { name: "myMetric" }, right: "topic" },
    #         { left: { name: "myDataset" }, right: "topic" }
    #       ]
    #     )
    #   end
    # end
  end
end
