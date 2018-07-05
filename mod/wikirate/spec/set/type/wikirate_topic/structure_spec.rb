
RSpec.describe Card::Set::Type::WikirateTopic::Structure do
  def card_subject
    Card["Force"]
  end

  check_views_for_errors :open_content, :listing, :edit, :homepage_item,
                 :details_tab, :wikirate_company_tab, :post_tab, :project_tab

  describe "view :browse_item" do
    it "has topic title" do
      expect_view(:browse_item).to have_tag "div.topic-header" do
        with_text "Force"
      end
    end

    it "has image link" do
      expect_view(:browse_item).to have_tag "div.company-content" do
        with_tag :a, with: { href: "http://wikirate.org/Force" } do
          with_tag :img
        end
      end
    end

    it "has counts with tab links" do
      expect_view(:browse_item).to have_tag "div.row.data-count" do
        with_tag "div.col-md-6.slab" do
          with_tag :a, with: { href: "/Force?tab=metric" } do
            with_text /1\s*Metric/
          end
        end
        with_tag "div.col-md-6.slab" do
          with_tag :a, with: { href: "/Force?tab=company" } do
            with_text /4\s*Companies/
          end
        end
      end
    end
  end
end
