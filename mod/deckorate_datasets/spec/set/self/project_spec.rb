# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Self::Project do
  let(:format) { format_subject :base }

  describe "filter_cql" do
    subject { format.filter_cql }

    it "has a featured project section" do
      expect_view(:titled_content).to have_tag("div.SELF-project-featured") do
        with_tag "div.item-box"
      end
    end

    it "filters for active projects by default" do
      is_expected.to eq(right_plus: [Card::WikirateStatusID, { refer_to: "Active" }])
    end
  end
end
