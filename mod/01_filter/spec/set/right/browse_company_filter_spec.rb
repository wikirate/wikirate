# -*- encoding : utf-8 -*-

require File.expand_path("../filter_spec_helper.rb", __FILE__)

describe Card::Set::Right::FilterSearchCompany do
  let(:card) do
    card = Card.new name: "test card"
    card.singleton_class.send :include, Card::Set::Right::FilterSearchCompany
    card
  end

  describe "filter_wql" do
    subject { card.filter_wql }

    def wql args
      args.merge type_id: Card::WikirateCompanyID
    end

    context "name argument" do
      before { filter_args name: "Animal Rights" }
      it { is_expected.to eq wql(name: ["match", "Animal Rights"]) }
    end

    context "topic argument" do
      before { filter_args wikirate_company: "Apple Inc" }
      it { is_expected.to eq wql(found_by: "Apple Inc+topic") }
    end

    context "industry argument" do
      before { filter_args metric: "myIndustry" }
      it do
        is_expected.to eq wql(
                              referred_to_by: { left: { name: "myMetric" }, right: "topic" }
                          )
      end
    end

    context "project argument" do
      before { filter_args project: "myProject" }
      it do
        is_expected.to eq wql(
                              referred_to_by: { left: { name: "myProject" }, right: "topic" }
                          )
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "Animal Rights",
                    wikirate_topic: "Apple Inc",
                    industry: "myIndustry",
                    project: "myProject"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq wql(
                              name: ["match", "Animal Rights"],
                              found_by: "Apple Inc+topic",
                              referred_to_by: [
                                  { left: { name: "myMetric" }, right: "topic" },
                                  { left: { name: "myProject" }, right: "topic" }
                              ]
                          )
      end
    end
  end
end
