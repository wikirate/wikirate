RSpec.describe Card::Set::Type::WikirateCompany::Structure do
  def card_subject
    Card["Google Inc"]
  end

  check_views_for_errors :open_content, :edit,
                         :wikirate_topic_tab, :source_tab, :post_tab, :project_tab

  describe "details tab" do
    it "has jurisdiction information" do
      expect(view(:details_tab, card: Card["Google LLC"]))
        .to have_tag("div.labeled-view.RIGHT-headquarter") do
          with_tag "span.card-title", text: "Headquarters"
          with_tag "div.RIGHT-headquarter.d0-card-content",
                   text: /California \(United States\)/
        end
    end
  end
end
