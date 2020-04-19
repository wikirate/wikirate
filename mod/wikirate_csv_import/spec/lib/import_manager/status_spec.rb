# TODO: move to card-mods

RSpec.describe ImportManager::Status do
  let(:status) { described_class.new }

  it "tracks items details in an items hash" do
    status.update_item 0, status: :importing
    expect(status.item_hash(0)[:status]).to eq(:importing)
  end

end