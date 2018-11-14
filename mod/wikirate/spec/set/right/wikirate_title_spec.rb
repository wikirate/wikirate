# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTitle do
  def card_subject
    Card.fetch [sample_source, :wikirate_title], new: {}
  end

  it "shows title if title exist" do
    card = card_subject
    card.content = "My Title"
    expect(card.format.render_needed).to eq("My Title")
  end

  it "shows \"title needed\" if title doesnt exist" do
    expect_view(:needed).to have_tag("span.wanted-card", text: "title needed")
  end
end
