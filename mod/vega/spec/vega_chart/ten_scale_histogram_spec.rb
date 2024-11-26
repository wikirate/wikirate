RSpec.describe Card::VegaChart::TenScaleHistogram do
  let(:metric) { Card["Jedi+darkness rating"] }
  let(:format) { metric.answer_card.format :json }
  let(:chart_class) { metric.chart_class }
  let(:chart_hash) { format.vega.hash }

  context "with Rating (more than 10 answers)" do
    before do
      format.define_singleton_method(:horizontal?) { false }
    end

    specify "chart_class" do
      expect(chart_class).to eq(:ten_scale_histogram)
    end

    specify "chart hash" do
      expect(chart_hash)
        .to include(
          data: a_collection_including(
            a_hash_including(
              transform: a_collection_including(a_hash_including(as: "floor"))
            )
          ),
          scales: a_collection_including(
            a_hash_including(name: "scoreColor")
          )
        )
    end
  end
end
