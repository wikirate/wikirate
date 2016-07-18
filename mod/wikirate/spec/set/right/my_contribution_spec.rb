describe Card::Set::Right::MyContributions do
  before do
    @user_card = Card["joe_user"]
    @user_contribution = @user_card.fetch trait: :my_contributions
  end
  def joe_plus codename
    "Joe_User+#{Card[codename].cardname.url_key}"
  end
  describe ".section" do
    it "returns count, name and contribution_card_name of contributions for " \
       "different types of card" do
      result = @user_contribution.sections
      # refer to seed.rb, 3 metrics with joe user as designer name
      expect(result).to(
        include([4, Card[:metric].name, joe_plus(:contributed_metrics)])
      )
      expect(result).to(
        include([0, Card[:claim].name, joe_plus(:contributed_claims)])
      )
      expect(result).to(
        include([0, Card[:source].name, joe_plus(:contributed_sources)])
      )
      expect(result).to(
        include([0, Card[:overview].name, joe_plus(:contributed_analysis)])
      )
      expect(result).to(
        include([0, Card[:project].name, joe_plus(:contributed_campaigns)])
      )
    end
  end

  describe "core view" do
    it "render the customized view " do
      html = @user_contribution.format.render_core
      expect(html).to(
        have_tag "div", with: { id: "Joe_User+contributed_sources" }
      ) do
        with_tag "span", with: { class: "card-title" }, text: "Source"
        with_tag "span", with: { class: "badge" }, text: "0"
      end
    end
  end

  describe "contribution_counts view" do
    def expect_link codename
      expect(@html).to(
        have_tag "a", with: { class: "item", href: "##{joe_plus codename}" }
      ) do
        yield
      end
    end

    it "render the counts for different contribution" do
      @html = @user_contribution.format.render_contribution_counts
      # refer to seed.rb, 3 metrics with joe user as designer name
      expect_link(:contributed_metrics) do
        with_tag "span", with: { class: "metric" }, text: "4"
        with_tag "p", with: { class: "legend" }, text: "Metric"
      end
      expect_link(:contributed_claims) do
        with_tag "span", with: { class: "note" }, text: "0"
        with_tag "p", with: { class: "legend" }, text: "Note"
      end
      expect_link(:contributed_sources) do
        with_tag "span", with: { class: "source" }, text: "0"
        with_tag "p", with: { class: "legend" }, text: "Source"
      end
      expect_link(:contributed_analysis) do
        with_tag "span", with: { class: "review" }, text: "0"
        with_tag "p", with: { class: "legend" }, text: "Review"
      end
      expect_link(:contributed_campaigns) do
        with_tag "span", with: { class: "project" }, text: "0"
        with_tag "p", with: { class: "legend" }, text: "Project"
      end
    end
  end

  describe "header view" do
    it "renders correct header view" do
      html = @user_contribution.format.render_header
      expect(html).to have_tag "div", with: { class: "card-header" } do
        with_tag "div", with: { class: "card-header-title" } do
          with_tag "span", with: { class: "card-title" }
          with_tag "div", with: { class: "counts" }
        end
      end
    end
  end
end
