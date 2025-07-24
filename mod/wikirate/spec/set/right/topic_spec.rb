# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Topic do
  let :invalid_topic_tagging do
    Card.create! name: "Lefty+Topic", content: "[[A]]\n[[B]]", type: :pointer
  end

  it "only allows existing topics" do
    expect { invalid_topic_tagging }.to raise_error(/invalid type: RichText/)
  end
end
