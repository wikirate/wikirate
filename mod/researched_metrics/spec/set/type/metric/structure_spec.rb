RSpec.describe Card::Set::Type::Metric::Structure do
  def card_subject
    Card["Jedi+disturbances in the Force"]
  end

  check_views_for_errors :open_content, :bar, :box, :edit,
                         :details_tab, :score_tab, :source_tab, :project_tab

  describe "view: bar_left" do
    it "has metric title" do
      expect_view(:bar_left).to have_tag "div.thumbnail" do
        with_tag "div.image-box"
        with_tag "div.thumbnail-text", text: /disturbances in the Force/
      end
    end
  end

  describe "view: bar_right" do
    it "has counts" do
      expect_view(:bar_right)
        .to have_badge_count(4, "RIGHT-company", "Companies")
    end
  end
end
