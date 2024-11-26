RSpec.describe Card::VegaChart::HorizontalBar do
  let(:format) { metric.answer_card.format :json }
  let(:chart_class) { metric.chart_class true }
  let(:chart_hash) { format.vega.hash }

  context "with Rating (10 or fewer answers)" do
    let(:metric) { Card["Jedi+darkness rating"] }

    specify "chart_class" do
      expect(chart_class).to eq(:horizontal_bar)
    end

    specify "chart hash" do
      expect(chart_hash)
        .to include(
          data: a_collection_including(
            a_hash_including(name: "companies"),
            a_hash_including(name: "answers")
          )
        )
    end
  end
end
