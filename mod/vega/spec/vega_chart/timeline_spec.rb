RSpec.describe Card::VegaChart::Timeline do
  let(:answer) { Card[:answer] }

  example "default timeline json" do
    expect(answer.format(:json).vega.hash)
      .to include(
        data: a_collection_including(
          a_hash_including(
            name: "counts",
            transform: a_collection_including(
              a_hash_including(expr: "{ route: datum.group }")
            )
          )
        )
      )
  end
end
