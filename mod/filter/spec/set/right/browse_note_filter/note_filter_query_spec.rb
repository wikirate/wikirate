# -*- encoding : utf-8 -*-

require File.expand_path("../../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::BrowseNoteFilter do
  describe "filter_wql" do
    subject { card.filter_wql_from_params }

    let(:card) do
      card = Card.new name: "test card"
      card.singleton_class.send :include, described_class
      card
    end

    def wql args
      args # .merge type_id: Card::ClaimID, limit: 15
    end

    context "name argument" do
      before { filter_args name: "claim" }
      it { is_expected.to eq wql(name: %w[match claim]) }
    end

    context "company argument" do
      before { filter_args wikirate_company: "Apple Inc" }
      it do
        is_expected.to eq wql(
          right_plus: [{ id: Card::WikirateCompanyID },
                       { refer_to: "Apple Inc" }]
        )
      end
    end

    context "topic argument" do
      before { filter_args wikirate_topic: "myTopic" }
      it do
        is_expected.to eq wql(
          right_plus: [{ id: Card::WikirateTopicID },
                       { refer_to: "myTopic" }]
        )
      end
    end

    context "cited" do
      before { filter_args cited: "yes" }
      it do
        is_expected.to eq wql(
          referred_to_by: {
            left: { type_id: Card::WikirateAnalysisID },
            right_id: Card::OverviewID
          }

        )
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "CDP",
                    wikirate_company: "Apple Inc",
                    wikirate_topic: "myTopic",
                    cited: "yes"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq wql(
          name: %w[match CDP],
          right_plus: [{ id: Card::WikirateTopicID },
                       { refer_to: "myTopic" }],
          and: {
            right_plus: [{ id: Card::WikirateCompanyID },
                         { refer_to: "Apple Inc" }]
          },
          referred_to_by: {
            left: { type_id: Card::WikirateAnalysisID },
            right_id: Card::OverviewID
          }
        )
      end
    end
  end
end
