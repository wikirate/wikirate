# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTitle do
  before do
    login_as "joe_user"
  end
  it "should show title if title exist" do
    # create the page with source with title
    url = "http://www.google.com/?q=wikirateissocoolandawesomeyouknowsigh"
    Card::Env.params[:sourcebox] = "true"
    sourcepage = Card.create type_id: Card::SourceID, subcards: { "+Link" => { content: url } }

    # link card
    title_card = Card["#{sourcepage.name}+title"]
    html = render_card :needed, name: title_card.name

    expect(html).to eq(title_card.content)
  end
  it "should show \"title needed\" if title doesnt exist" do
    # create the page with source
    url = "http://www.google.com/?q=wikirateissocoolandawesomeyouknowsigh"

    sourcepage = Card.create type_id: Card::SourceID, subcards: { "+Link" => { content: url } }
    Card[sourcepage.name + "+Title"].delete! if Card[sourcepage.name + "+Title"]
    html = render_card :needed, name: "#{sourcepage.name}+Title"
    expect(html).to eq("<span class=\"wanted-card\">title needed</span>")
  end
end
