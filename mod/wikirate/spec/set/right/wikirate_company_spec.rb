# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateCompany do
  before do
    login_as "joe_user"
  end
  it "creates company card(s) while creating +companies card(s)" do
    # create the webpage first
    url = "http://www.google.com/?q=newpage"
    Card::Env.params[:sourcebox] = "true"
    sourcepage = Card.create! type_id: Card::SourceID,
                              subcards: { "+Link" => { content: url } }
    Card::Env.params[:sourcebox] = "false"

    Card.create! type_id: Card::ClaimID, name: "Testing Claim",
                 subcards: {
                   "+Company" => {
                     content: "[[zzz]]\n[[xxx]]",
                     type: "pointer"
                   },
                   "+source" => {
                     content: "[[#{sourcepage.name}]]",
                     type_id: Card::PointerID
                   }
                 }
    expect(Card.exists?("zzz")).to be true
    expect(Card.exists?("xxx")).to be true
    expect(Card["zzz"].type_id).to eq Card::WikirateCompanyID
    expect(Card["xxx"].type_id).to eq Card::WikirateCompanyID
  end
end
