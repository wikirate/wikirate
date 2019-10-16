# -*- encoding : utf-8 -*-

require File.expand_path("../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseCompanyFilter do
  describe "filter_wql" do
    subject { card_subject.filter_wql_from_params }

    def wql args
      args # .merge type_id: Card::WikirateCompanyID
    end

    context "name argument" do
      before { filter_args name: "Apple" }
      it { is_expected.to eq wql(name: %w[match Apple]) }
    end

    context "company group argument" do
      before { filter_args company_group: "Deadliest" }
      it { is_expected.to eq wql(referred_to_by: "Deadliest+Company") }
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
        is_expected.to eq wql(referred_to_by: "myProject+Company")
      end
    end

    context "multiple filter conditions" do
      before do
        filter_args name: "Apple",
                    industry: "myIndustry",
                    project: "myProject"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq wql(
          name: %w[match Apple],
          left_plus: [
            "Global Reporting Initiative+Sector Industry", {
              right_plus: ["2015", { right_plus: ["value", { eq: "myIndustry" }] }]
            }
          ],
          referred_to_by: "myProject+Company"
        )
      end
    end
  end
end
