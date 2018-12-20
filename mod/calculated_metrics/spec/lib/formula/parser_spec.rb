
RSpec.describe Formula::Parser do
  example "CountRelated translation" do
    parser = described_class.new "CountRelated[M2]"
    expect(parser.formula) .to eq "Total[ {{always one|company: Related[M2]}} ]"
  end
end
