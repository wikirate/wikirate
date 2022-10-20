RSpec.describe Card::Set::Self::Dataset do
  check_views_for_errors :csv

  def card_subject
    :dataset.card
  end

  describe "view core" do
    it "has a description card" do
      expect_view(:titled_content).to have_tag("div.RIGHT-description")
    end

    it "has a featured dataset section" do
      expect_view(:titled_content).to have_tag("div.SELF-datum_set-featured") do
        with_tag "div.item-bar"
      end
    end

    it "filters datasets" do
      expect_view(:titled_content).to have_tag("div._filtered-content") do
        with_tag "div._filtered-content" do
          with_tag "div.bar-view", with: { "data-card-name": "Evil Dataset" }
        end
      end
    end
  end
end
