RSpec.describe Card::VegaChart::Timeline do
  let(:answer) { Card[:metric_answer] }

  example "default timeline json" do
    expect(answer.format(:json).vega.hash)
      .to include(
        data: a_collection_including(
          a_hash_including(
            name: "counts",
            transform: a_collection_including(
              a_hash_including(expr: "{ value_type: datum.group }")
            )
          )
        )
      )
  end
end
