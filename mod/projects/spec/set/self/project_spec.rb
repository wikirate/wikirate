RSpec.describe Card::Set::Self::Project do
  describe "view core" do
    it "has a description card" do
      expect_view(:core).to have_tag("div.RIGHT-description")
    end

    it "has a featured projects section" do
      expect_view(:core).to have_tag("div.SELF-homepage_featured_project") do
        with_tag "div.item-bar"
      end
    end

    it "filters projects" do
      expect_view(:core).to have_tag("div._filtered-content") do
        with_tag "div.filter-form"
        with_tag "div.filtered-results" do
          with_tag "div.bar-view", with: { "data-card-name": "Evil Project" }
        end
      end
    end
  end
end
