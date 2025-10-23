RSpec.describe Card::Set::Type::Source::Json do
  def card_subject
    Card[:darth_vader_source]
  end

  specify "view: :molecule" do
    expect_view(:molecule, format: :jsonld)
      .to include("@type" => "Source",
                  "@id" => a_kind_of(String),
                  "@context" => "/context/Source.jsonld")
  end
end
