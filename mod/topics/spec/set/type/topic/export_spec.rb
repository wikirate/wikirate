RSpec.describe Card::Set::Type::Topic::Export do
  let(:name) { "Wikirate_ESG_Topics+Supplier_Code_of_Conduct"}

  def card_subject
    Card[name]
  end

  specify "view: :molecule" do
    expect_view(:molecule, format: :jsonld)
      .to include(:@type => "Topic",
                  :@id => a_kind_of(String),
                  :@context => "/context/Topic.jsonld")
  end
end
