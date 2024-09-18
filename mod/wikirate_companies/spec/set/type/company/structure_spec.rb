RSpec.describe Card::Set::Type::Company::Structure do
  def card_subject
    Card["Google Inc"]
  end

  check_views_for_errors

  describe "view: :header_middle" do
    it "has HQ information" do
      expect(view(:header_middle, card: Card["Google LLC"]))
        .to have_tag("div.header-list-item") do
          with_tag "label", text: /Headquarters:/
          with_tag "span", text: /California \(United States\)/
        end
    end
  end
end
