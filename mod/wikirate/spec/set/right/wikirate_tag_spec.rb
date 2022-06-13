# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTag do
  before do
    login_as "joe_user"
  end
  it "creates tag card(s) while creating +tag card(s)" do
    # create the webpage first
    Card.create! name: "Tagged+tag", content: "[[zzz]]\n[[xxx]]", type: :pointer
    expect(Card.exists?("zzz")).to be true
    expect(Card.exists?("xxx")).to be true
  end
end
