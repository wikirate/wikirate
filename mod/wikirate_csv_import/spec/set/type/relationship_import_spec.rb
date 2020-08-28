RSpec.describe Card::Set::Type::RelationshipImport do
  def card_subject
    Card["relationship import test"]
  end

  let :answer_name do
    "Jedi+more evil+Death Star+2000"
  end

  example "it correctly updates counts for answers with multiple relationships" do
    card_subject.import! [9, 10]
    expect(Card[answer_name, "Google Inc"]).to be_present
    expect(Card[answer_name, "SPECTRE"]).to be_present
    expect(Card[answer_name].value).to eq("2")
    expect(Card["Jedi+less evil+SPECTRE+2000"].value).to eq("1")
  end
end
