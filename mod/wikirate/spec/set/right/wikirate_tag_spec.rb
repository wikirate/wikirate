# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTag do
  before do
    login_as "joe_user"
  end
  it "creates tag card(s) while creating +tag card(s)" do
    # create the webpage first
    url = "http://www.google.com/?q=newpage"
    Card::Env.params[:sourcebox] = "true"
    sourcepage = Card.create! type_id: Card::SourceID, subcards: { "+Link" => { content: url } }
    Card::Env.params[:sourcebox] = "false"

    card = Card.create! type_id: Card::ClaimID, name: "Testing Claim", subcards: { "+tag" => { content: "[[zzz]]\n[[xxx]]", type: "pointer" }, "+source" => { content: "[[#{sourcepage.name}]]", type_id: Card::PointerID } }
    expect(Card.exists?("zzz")).to be true
    expect(Card.exists?("xxx")).to be true
  end
end
