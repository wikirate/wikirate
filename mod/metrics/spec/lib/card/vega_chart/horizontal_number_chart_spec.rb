RSpec.describe Card::VegaChart::HorizontalNumberChart do
  let(:format) { metric.metric_answer_card.format :json }
  let(:chart_class) { format.chart_class }
  let(:chart_hash) { format.vega_chart_config.to_hash }

  context "with WikiRating (10 or fewer answers)" do
    let(:metric) { Card["Jedi+darkness rating"]}

    specify "chart_class" do
      expect(chart_class).to eq(described_class)
    end

    specify "chart hash" do
      expect(chart_hash)
        .to include(
              data: a_collection_including(
                a_hash_including(
                  values: a_collection_including(
                    a_hash_including(details: "Jedi+darkness_rating+Death_Star+1977")
                  )
                )
              )
            )
    end
  end
end