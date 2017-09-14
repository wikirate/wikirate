describe Card::Set::Type::WikirateTopic do
  it "shows the link for view \"missing\"" do
    html = render_card :missing, type_id: Card::WikirateTopicID, name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateTopicID, name: "non-existing-card"))
  end
end
