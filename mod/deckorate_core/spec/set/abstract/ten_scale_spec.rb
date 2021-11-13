RSpec.describe Card::Set::Abstract::TenScale do
  describe "#colorify" do
    it "adds correct color class" do
      expect(format_subject.colorify("3.49")).to(
        have_tag ".range-value.score-color-3", text: /3\.5/
      )
    end
  end

  describe "#ten_scale_decimal" do
    def ten_scale value
      format_subject.ten_scale_decimal value
    end

    it "returns 10 for 10.0" do
      expect(ten_scale(10.0)).to eq "10"
    end

    it "handles numbers between 1 and 10" do
      expect(ten_scale(5.678)).to eq "5.7"
    end

    it "handles numbers between 0 and 1" do
      expect(ten_scale(0.234)).to eq "0.2"
    end

    it "returns 0.0 for 0" do
      expect(ten_scale(0)).to eq "0.0"
    end
  end
end
