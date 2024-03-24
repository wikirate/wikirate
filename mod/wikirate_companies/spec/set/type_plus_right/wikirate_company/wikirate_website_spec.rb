RSpec.describe Card::Set::TypePlusRight::WikirateCompany::WikirateWebsite do
  it "validates website" do
    expect { card_subject.update! content: "www.whatever.com" }
      .to raise_error(/must be url/)
    expect { card_subject.update! content: "https://www.whatever.com" }
      .not_to raise_error
  end
end
