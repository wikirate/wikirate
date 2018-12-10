# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTopic do
  before do
    login_as "joe_user"
  end
  it "creates topic card(s) while creating +topics card(s)" do
    Card.create! name: "Lefty+Topic", content: "[[zzz]]\n[[xxx]]", type: :pointer
    expect(Card.exists?("zzz")).to be true
    expect(Card.exists?("xxx")).to be true
    expect(Card["zzz"].type_id).to eq Card::WikirateTopicID
    expect(Card["xxx"].type_id).to eq Card::WikirateTopicID
  end
end
