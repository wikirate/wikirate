# TODO: move to card-mods

RSpec.describe Card::ImportManager::Status do
  let(:status) { described_class.new }

  describe "#update_item" do
    it "enters items as arrays of data" do
      status.update_item 0, status: :importing, id: 1234
      expect(status[:items].first).to eq([:importing, 1234])
    end

    it "clears errors (but not ids) each time it is called" do
      status.update_item 0, status: :importing, id: 1234, error: "chose wrong career"
      expect(status.item_hash(0)[:error]).to eq("chose wrong career")
      expect(status.item_hash(0)[:id]).to eq(1234)

      status.update_item 0, status: :imported
      expect(status.item_hash(0)[:error]).to be_nil
      expect(status.item_hash(0)[:id]).to eq(1234)
    end
  end

  describe "#item_hash" do
    it "can return items details as a hash" do
      status.update_item 0, status: :importing
      expect(status.item_hash(0)[:status]).to eq(:importing)
    end
  end
end
