# -*- encoding : utf-8 -*-

require File.expand_path("../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::BrowseCompanyFilter do
  let(:card) do
    card = Card.new name: "test card"
    card.singleton_class.send :include, described_class
    card
  end

  describe "filter_wql" do
    subject { card.filter_wql_from_params }

    def wql args
      args # .merge type_id: Card::WikirateCompanyID
    end

    context "name argument" do
      before { filter_args name: "Apple" }
      it { is_expected.to eq wql(name: %w[match Apple]) }
    end

    context "topic argument" do
      before { filter_args wikirate_topic: "Animal Rights" }
      it { is_expected.to eq wql(found_by: "Animal Rights+Company+*refers to") }
    end

    context "industry argument" do
      before { filter_args industry: "myIndustry" }
      it do
        is_expected.to eq wql(
          left_plus: ["Global Reporting Initiative+Sector Industry",
                      { right_plus: ["2015",
                                     { right_plus: ["value", { eq: "myIndustry" }] }] }]
        )
      end
    end

    context "project argument" do
      before { filter_args project: "myProject" }
      it do
        is_expected.to eq wql(
          referred_to_by: { left: "myProject", right: :wikirate_company }
        )
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "Apple",
                    wikirate_topic: "Animal Rights",
                    industry: "myIndustry",
                    project: "myProject"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq wql(
          name: %w[match Apple],
          found_by: "Animal Rights+Company+*refers to",
          left_plus: [
            "Global Reporting Initiative+Sector Industry", {
              right_plus: ["2015", { right_plus: ["value", { eq: "myIndustry" }] }]
            }
          ],
          referred_to_by: { left: "myProject", right: :wikirate_company }
        )
      end
    end
  end
end
