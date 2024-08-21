RSpec.describe Card::Set::Self::Dataset do
  check_views_for_errors
  check_views_for_errors format: :csv, views: views(:csv).push(:titled)

  describe "view core" do
    it "has a description card" do
      expect_view(:titled_content).to have_tag("div.RIGHT-description")
    end

    it "has a featured dataset section" do
      expect_view(:titled_content).to have_tag("div.SELF-dataset-featured") do
        with_tag "div.item-box"
      end
    end

    it "filters datasets" do
      expect_view(:filtered_content).to have_tag("div._filtered-content") do
        with_tag "div._filtered-content" do
          with_tag "div.bar-view", with: { "data-card-name": "Evil Dataset" }
        end
      end
    end
  end
end
