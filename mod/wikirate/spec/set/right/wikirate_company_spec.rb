# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateCompany do
  before do
    login_as "joe_user"
  end
  it "creates company card(s) while creating +companies card(s)" do
    Card.create! name: "Lefty",
                 subcards: { "+Company" => { content: "[[zzz]]\n[[xxx]]",
                                             type: "pointer" } }
    expect(Card.exists?("zzz")).to be true
    expect(Card.exists?("xxx")).to be true
    expect(Card["zzz"].type_id).to eq Card::WikirateCompanyID
    expect(Card["xxx"].type_id).to eq Card::WikirateCompanyID
  end
end
