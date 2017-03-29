RSpec.describe Card::Set::All::ActBadgeCount do
  let(:card) { Card[:home] }

  describe "#act_badge_count" do
    it "is zero" do
      expect(card.act_badge_count :company, "Apple").to eq 0
    end

    context "if increased" do
      before do
        card.act_badge_count_step :company, "Apple"
      end
      it "is one" do
        expect(card.act_badge_count :company, "Apple").to eq 1
      end
    end

    context "if increased twice" do
      before do
        card.act_badge_count_step :company, "Apple"
        card.act_badge_count_step :company, "Apple"
      end
      it "is two" do
        expect(card.act_badge_count :company, "Apple").to eq 2
      end
    end
  end
end
