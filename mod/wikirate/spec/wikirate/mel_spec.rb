RSpec.describe Wikirate::MEL do
  it "records without raising error" do
    expect { described_class.new(period: "1 month").record }.not_to raise_error
  end
end
