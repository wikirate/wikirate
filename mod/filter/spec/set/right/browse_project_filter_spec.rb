# -*- encoding : utf-8 -*-

# require File.expand_path("../filter_spec_helper.rb", __FILE__)

RSpec.describe Card::Set::Right::BrowseProjectFilter do
  describe "#filter_wql" do
    subject { card_subject.filter_wql }

    it "filters for active projects by default" do
      is_expected.to eq(right_plus: [Card::WikirateStatusID, { refer_to: "Active" }])
    end
  end
end
