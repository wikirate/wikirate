# -*- encoding : utf-8 -*-

describe Card::Set::Right::WikirateTopic do
  let :invalid_topic_tagging do
    Card.create! name: "Lefty+Topic", content: "[[zzz]]\n[[xxx]]", type: :pointer
  end

  it "only allows existing topics" do
    expect { invalid_topic_tagging }.to raise_error(/invalid topic/)
  end
end
