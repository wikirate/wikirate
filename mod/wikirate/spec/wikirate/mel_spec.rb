RSpec.describe Wikirate::MEL do
  it "records without raising error" do
    expect { described_class.record }.not_to raise_error
  end
end
