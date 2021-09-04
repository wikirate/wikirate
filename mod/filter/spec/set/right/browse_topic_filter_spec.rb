# -*- encoding : utf-8 -*-

require File.expand_path("../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseTopicFilter do
  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql_from_params }

    def cql args
      args # merge type_id: Card::WikirateTopicID
    end

    context "name argument" do
      before { filter_args name: "Animal Rights" }
      it { is_expected.to eq cql(name: ["match", "Animal Rights"]) }
    end

    context "company argument" do
      before { filter_args wikirate_company: "Apple Inc" }
      it { is_expected.to eq cql(found_by: "Apple Inc+topic") }
    end

    context "metric argument" do
      before { filter_args metric: "myMetric" }
      it do
        is_expected.to eq cql(
          referred_to_by: { left: { name: "myMetric" }, right: "topic" }
        )
      end
    end

    context "with dataset argument" do
      before { filter_args dataset: "myDataset" }
      it do
        is_expected.to eq cql(
          referred_to_by: { left: { name: "myDataset" }, right: "topic" }
        )
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "Animal Rights",
                    wikirate_company: "Apple Inc",
                    metric: "myMetric",
                    dataset: "myDataset"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq cql(
          name: ["match", "Animal Rights"],
          found_by: "Apple Inc+topic",
          referred_to_by: [
            { left: { name: "myMetric" }, right: "topic" },
            { left: { name: "myDataset" }, right: "topic" }
          ]
        )
      end
    end
  end
end
