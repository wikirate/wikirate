RSpec.describe Card::Set::TypePlusRight::Metric::Unpublished do
  let(:metric) { Card["Jedi+disturbances in the Force"] }
  let(:record) { Card["Jedi+disturbances in the Force+Death Star+2000"] }
  let(:wikirating) { Card["Jedi+darkness rating"] }

  let(:unpublished_vals) do
    Record.where(metric_id: metric.id).pluck(:unpublished).uniq
  end

  describe "event: toggle record publication" do
    before do
      metric.unpublished_card.update! content: 1
    end

    it "updates records upon publishing" do
      expect(unpublished_vals).to eq([true])
    end

    it "updates records upon unpublishing" do
      metric.unpublished_card.update! content: 0
      expect(unpublished_vals).to eq([false])
    end

    it "does not publish records flagged as unpublished" do
      record.unpublished_card.update! content: 1
      metric.unpublished_card.update! content: 0
      expect(unpublished_vals).to include(true).and include(false)
    end

    it "unpublishes its calculations" do
      expect(wikirating).to be_unpublished
    end

    it "is published when wikirating is published" do
      wikirating.unpublished_card.update! content: 1
      wikirating.unpublished_card.update! content: 0
      expect(metric).to be_published
    end
  end
end
