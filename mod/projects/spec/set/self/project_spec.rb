describe Card::Set::Self::Project do
  describe "view core" do
    it "has a description card" do
      expect_view(:core).to have_tag("div.RIGHT-description")
    end

    it "has a featured projects section" do
      expect_view(:core).to have_tag("div.SELF-homepage_featured_project") do
        with_tag "div.item-listing"
      end
    end

    it "lists all projects in tabs" do
      expect_view(:core).to have_tag("div.tabbable") do
        with_tag "ul.nav-tabs" do
          with_tag "span.card-title", "Active"
        end
        with_tag "div.tab-content" do
          with_tag "div.item-listing"
        end
      end
    end
  end
end
