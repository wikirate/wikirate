# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTopic do
  it "only allows existing topics" do
    expect {
      Card.create! name: "Lefty+Topic", content: "[[zzz]]\n[[xxx]]", type: :pointer
    }.to raise_error(/invalid topic/)
  end
end
