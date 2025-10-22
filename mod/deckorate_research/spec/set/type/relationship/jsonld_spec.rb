RSpec.describe Card::Set::Type::Relationship::Jsonld do
  let(:name) { "Commons+Supplied by+Monster_Inc+1977+Los_Pollos_Hermanos" }

  def card_subject
    Card[name]
  end

  specify "view: :molecule" do
    expect_view(:molecule, format: :jsonld)
      .to include("@type" => "Relationship",
                  "@id" => a_kind_of(String),
                  "@context" => "/context/Relationship.jsonld")
  end
end
