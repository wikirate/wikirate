RSpec.describe Card::Set::Type::Answer::Jsonld do
  let(:name) { "Jedi+disturbances_in_the_Force+Death_Star+2001"}

  def card_subject
    Card[name]
  end

  specify "view: :molecule" do
    expect_view(:molecule, format: :jsonld)
      .to include("@type" => "Answer",
                  "@id" => a_kind_of(String),
                  "@context" => "/context/Answer.jsonld")
  end
end
