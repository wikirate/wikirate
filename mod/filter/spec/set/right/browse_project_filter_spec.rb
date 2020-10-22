# -*- encoding : utf-8 -*-

# require File.expand_path("../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseProjectFilter do
  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql }

    it "filters for active projects by default" do
      is_expected.to eq(right_plus: [Card::WikirateStatusID, { refer_to: "Active" }])
    end
  end
end
