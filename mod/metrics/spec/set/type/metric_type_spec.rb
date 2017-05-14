# -*- encoding : utf-8 -*-

describe Card::Set::Type::Metric do
  describe "#metric_type" do
    subject do
      Card::Auth.as_bot do
        Card.create! name: ""
      end
    end
  end
end
