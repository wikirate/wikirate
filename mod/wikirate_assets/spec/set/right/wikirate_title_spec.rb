# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTitle do
  def card_subject
    Card.fetch [sample_source, :wikirate_title], new: {}
  end

  it "shows title if title exist" do
    expect_view(:needed).to eq("Opera")
  end

  it "shows \"title needed\" if title doesnt exist" do
    card_subject.content = ""
    expect_view(:needed).to have_tag("span.wanted-card", text: "title needed")
  end
end
