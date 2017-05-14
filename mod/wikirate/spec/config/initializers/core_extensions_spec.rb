describe CoreExtensions do
  describe String do
    describe "#number?" do
      it "true for a valid number" do
        expect("6".number?).to eq(true)
      end

      it "false for an invalid number" do
        expect("Yomama".number?).to eq(false)
      end
    end
  end
end
