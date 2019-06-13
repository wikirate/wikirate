RSpec.describe Card::Set::Type::WikirateCompany::Listing do
  def card_subject
    Card["Death Star"]
  end

  check_views_for_errors :bar, :expanded_bar, :box

  describe "view: bar_left" do
    it "has company title" do
      expect_view(:bar_left).to have_tag "div.thumbnail" do
        with_tag "div.image-box"
        with_tag "div.thumbnail-text", text: /Death Star/
      end
    end
  end

  describe "view: bar_right" do
    it "has counts" do
      expect_view(:bar_right).to have_badge_count(metric_count, "RIGHT-metric", "Metrics")
    end
  end
end
