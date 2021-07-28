RSpec.describe Card::Set::Type::WikirateTopic do
  def card_subject
    Card["Force"]
  end

  check_html_views_for_errors

  describe "view: bar_left" do
    it "has topic title" do
      expect_view(:bar_left).to have_tag "div.thumbnail" do
        with_tag "div.image-box"
        with_tag "div.thumbnail-text", text: /Force/
      end
    end
  end

  describe "view: bar_right" do
    it "has counts with tab links" do
      expect_view(:bar_right).to have_badge_count(1, "RIGHT-metric", "Metrics")
      # expect_view(:bar_right).to have_badge_count(4, "RIGHT-company", "Companies")
    end
  end

  it "shows the link for view \"unknown\"" do
    html = render_card :unknown, type_id: Card::WikirateTopicID, name: "non-existing-card"
    expect(html).to eq(render_card(:link, type_id: Card::WikirateTopicID,
                                          name: "non-existing-card"))
  end
end
