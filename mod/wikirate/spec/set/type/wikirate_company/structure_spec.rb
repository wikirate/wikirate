RSpec.describe Card::Set::Type::WikirateCompany::Structure do
  def card_subject
    Card["Google Inc"]
  end

  check_views_for_errors :open_content, :edit,
                         :wikirate_topic_tab, :source_tab, :post_tab, :project_tab

  describe "details tab" do
    it "has jurisdiction table" do
      expect(view(:details_tab, card: Card["Google LLC"])).to have_tag "table" do
        with_tag :tr do
          with_tag :td, text: "Headquarters"
          with_tag :td, text: "California (United States)"
        end
      end
    end
  end
end
