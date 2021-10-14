# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Project do
  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql }

    it "filters for active projects by default" do
      is_expected.to eq(right_plus: [Card::WikirateStatusID, { refer_to: "Active" }])
    end
  end
end
