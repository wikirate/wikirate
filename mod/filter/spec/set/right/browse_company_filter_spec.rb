# -*- encoding : utf-8 -*-

require File.expand_path("../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseCompanyFilter do
  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql_from_params }

    def cql args
      args # .merge type_id: Card::WikirateCompanyID
    end

    context "with name argument" do
      before { filter_args name: "Apple" }
      it { is_expected.to eq cql(name: %w[match Apple]) }
    end

    context "with company group argument" do
      before { filter_args company_group: "Deadliest" }
      it { is_expected.to eq cql(and: { referred_to_by: "Deadliest+Company" }) }
    end

    context "with industry argument" do
      before { filter_args industry: "myIndustry" }
      it do
        is_expected.to eq cql(
          left_plus: ["Global Reporting Initiative+Sector Industry",
                      { right_plus: ["2015",
                                     { right_plus: ["value", { eq: "myIndustry" }] }] }]
        )
      end
    end

    context "with project argument" do
      before { filter_args project: "myProject" }
      it do
        is_expected.to eq cql(and: { referred_to_by: "myProject+Company" })
      end
    end

    context "with multiple filter conditions" do
      before do
        filter_args name: "Apple",
                    industry: "myIndustry",
                    project: "myProject"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq cql(
          name: %w[match Apple],
          left_plus: [
            "Global Reporting Initiative+Sector Industry", {
              right_plus: ["2015", { right_plus: ["value", { eq: "myIndustry" }] }]
            }
          ],
          and: { referred_to_by: "myProject+Company" }
        )
      end
    end
  end
end
