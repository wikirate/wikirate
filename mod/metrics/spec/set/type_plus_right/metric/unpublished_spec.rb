RSpec.describe Card::Set::TypePlusRight::Metric::Unpublished do
  let(:metric) { Card["Jedi+disturbances in the Force"] }
  let(:answer) { Card["Jedi+disturbances in the Force+Death Star+2000"] }

  let(:unpublished_vals) do
    Answer.where(metric_id: metric.id).pluck(:unpublished).uniq
  end

  describe "event: toggle answer publication" do
    it "updates answers upon publishing" do
      metric.unpublished_card.update! content: 1
      expect(unpublished_vals).to eq([true])
    end

    it "updates answers upon unpublishing" do
      metric.unpublished_card.update! content: 1
      metric.unpublished_card.update! content: 0
      expect(unpublished_vals).to eq([false])
    end

    it "does not publish answers flagged as unpublished" do
      answer.unpublished_card.update! content: 1
      metric.unpublished_card.update! content: 1
      metric.unpublished_card.update! content: 0
      expect(unpublished_vals).to include(true).and include(false)
    end
  end
end
