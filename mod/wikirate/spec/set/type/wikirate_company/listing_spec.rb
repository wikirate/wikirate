RSpec.describe Card::Set::Type::WikirateCompany::Listing do
  def card_subject
    Card["Death Star"]
  end

  check_views_for_errors :bar, :box

  describe "view: bar_left" do
    it "has topic title" do
      expect_view(:bar_left).to have_tag "div.thumbnail" do
        with_tag "div.image-box"
        with_tag "div.thumbnail-text", text: /Death Star/
      end
    end
  end

  describe "view: bar_right" do
    it "has counts with tab links" do
      expect_view(:bar_right).to have_badge_count(metric_count, "RIGHT-metric", "Metrics")
    end
  end
end
