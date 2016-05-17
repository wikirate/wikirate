describe Card::Set::All::Base do
  before do
    login_as "joe_user"
  end
  it "handles paragraph view" do
    card = Card.create name: "test_basic", type: "basic", content: "abc " * 150
    html = card.format.render_paragraph
    expect(html.scan(/abc/).length).to eq(100)
  end
  it "handles preview view" do
    card = Card.create name: "test_basic", type: "basic", content: "abc " * 50
    html = card.format.render_preview
    expect(html.scan(/abc/).length).to eq(40)
  end
end
