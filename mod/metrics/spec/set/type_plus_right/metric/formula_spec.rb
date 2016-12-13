# encoding: UTF-8

describe Card::Set::TypePlusRight::Metric::Formula do
  describe '#ruby_formula?' do
    subject do
      Card["Jedi+friendliness+formula"]
    end
    it "allows math operations" do
      subject.content = "5 * 4 / 2 - 2.3 + 5"
      expect(subject.ruby_formula?).to be_truthy
    end

    it "allows parens" do
      subject.content = "5 * (4 / 2) - 2"
      expect(subject.ruby_formula?).to be_truthy
    end

    it "allows nests" do
      subject.content = "5 * {{metric}} + 5"
      expect(subject.ruby_formula?).to be_truthy
    end

    it "denies letters" do
      subject.content = "5 * 4*a / 2"
      expect(subject.ruby_formula?).to be_falsey
    end
  end
end
