describe CoreExtensions do
  describe String do
    it "may be a valid number" do
      expect("6".number?).to eq(true)
    end

    it "may not be a valid number" do
      expect("Yomama".number?).to eq(false)
    end
  end
end
