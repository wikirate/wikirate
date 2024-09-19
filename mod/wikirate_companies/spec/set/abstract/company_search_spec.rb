# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::CompanySearch do
  include FilterSpecHelper

  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql_from_params }

    def cql args
      args # .merge type_id: Card::CompanyID
    end

    context "with name argument" do
      before { filter_args name: "Apple" }
      it { is_expected.to eq cql(name: %w[match Apple]) }
    end

    context "with company group argument" do
      before { filter_args company_group: "Deadliest" }
      it { is_expected.to eq cql(and: { referred_to_by: "Deadliest+Company" }) }
    end

    context "with company_category argument" do
      before { filter_args company_category: "myIndustry" }
      it { is_expected.to eq cql(company_category: "myIndustry") }
    end

    context "with company_identifier argument" do
      before { filter_args company_identifier: { type: "Wikipedia" } }
      it { is_expected.to eq cql(right_plus: ["Wikipedia", {}]) }
    end

    context "with dataset argument" do
      before { filter_args dataset: "myDataset" }
      it do
        is_expected.to eq cql(and: { referred_to_by: "myDataset+Company" })
      end
    end

    context "with multiple filter conditions" do
      before do
        filter_args name: "Apple",
                    company_category: "myIndustry",
                    dataset: "myDataset"
      end
      it "joins filter conditions correctly" do
        is_expected.to eq cql(
          name: %w[match Apple],
          company_category: "myIndustry",
          and: { referred_to_by: "myDataset+Company" }
        )
      end
    end
  end
end
