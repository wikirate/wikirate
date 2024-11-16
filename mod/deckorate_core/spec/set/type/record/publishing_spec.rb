# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Record::Publishing do
  let(:record) { Card["Jedi+deadliness+Death_Star+1977"] }

  describe "#check_published" do
    context "when record published" do
      it "grants access to all, even non-stewards" do
        expect(record).to be_ok(:read)
      end
    end

    context "when record unpublished" do
      before do
        record.unpublished_card.update! content: 1
      end

      it "denies access to non-stewards" do
        expect(record).not_to be_ok(:read)
      end

      it "denies access to fields to non-stewards" do
        expect(record.value_card).not_to be_ok(:read)
      end

      it "grants access to stewards" do
        record.metric_card.steward_card.update! content: "Joe User"
        expect(record).to be_ok(:read)
      end
    end
  end
end
