RSpec.describe Card::VegaChart::TenScaleChart do
  let(:metric) { Card["Jedi+darkness rating"]}
  let(:format) { metric.metric_answer_card.format :json }
  let(:chart_class) { format.chart_class }
  let(:chart_hash) { format.vega_chart_config.to_hash }

  context "with WikiRating (more than 10 answers)" do
    before do
      format.define_singleton_method(:chart_item_count) { 11 }
    end

    specify "chart_class" do
      expect(chart_class).to eq(described_class)
    end

    specify "chart hash" do
      expect(chart_hash)
        .to include(
              data: a_collection_including(
                a_hash_including(
                  values: a_collection_including(
                    a_hash_including(filter: { value: { from: 0, to: 1 } }),
                    a_hash_including(filter: { value: { from: 10, to: 11 } }),
                  )
                )
              )
            )
    end
  end
end