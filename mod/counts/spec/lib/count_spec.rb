RSpec.describe Count do
  let(:card) do
    double("count card", junction?: true, recount: 10, left_id: 1, right_id: 5)
  end
  let(:create_count) { Count.create(card) }

  describe ".create" do
    it "has count 10" do
      expect(create_count.value).to eq 10
    end
  end

  describe ".fetch_value" do
    context "existing entry" do
      it "returns 10" do
        create_count
        expect(Count.fetch_value card).to eq 10
      end
    end

    context "new entry" do
      it "returns 10" do
        expect(Count.fetch_value card).to eq 10
      end
    end
  end

  describe ".refresh" do
    it "returns 15" do
      expect(Count.fetch_value card).to eq 10
      allow(card).to receive(:recount).and_return 15
      Count.refresh card
      expect(Count.fetch_value card).to eq 15
    end
  end

  describe ".step" do
    context "existing entry" do
      it "returns 11" do
        create_count
        expect(Count.step card).to eq 11
      end
    end

    context "new entry" do
      it "returns 10" do
        expect(Count.step card).to eq 10
      end
    end
  end
end
