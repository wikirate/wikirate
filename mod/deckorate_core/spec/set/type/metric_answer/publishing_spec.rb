# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::MetricAnswer::Publishing do
  let(:answer) { Card["Jedi+deadliness+Death_Star+1977"] }

  describe "#check_published" do
    context "when answer published" do
      it "grants access to all, even non-stewards" do
        expect(answer).to be_ok(:read)
      end
    end

    context "when answer unpublished" do
      before do
        answer.unpublished_card.update! content: 1
      end

      it "denies access to non-stewards" do
        expect(answer).not_to be_ok(:read)
      end

      it "denies access to fields to non-stewards" do
        expect(answer.value_card).not_to be_ok(:read)
      end

      it "grants access to stewards" do
        answer.metric_card.steward_card.update! content: "Joe User"
        expect(answer).to be_ok(:read)
      end
    end
  end
end
