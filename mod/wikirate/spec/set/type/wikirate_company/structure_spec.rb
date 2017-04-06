
RSpec.describe Card::Set::Type::WikirateCompany::Structure do
  subject { Card["Death Star"].format(:html)._render_browse_item }

  describe "view :browse_item" do
    it "has company title" do
      is_expected.to have_tag "div.company-header" do
        with_text "Death Star"
      end
    end

    it "has image link" do
      is_expected.to have_tag "div.company-page-logo-container" do
        with_tag :a, with: { href: "http://wikirate.org/Death_Star" } do
          with_tag :img
        end
      end
    end

    it "has counts with tab links" do
      is_expected.to have_tag "div.row.data-count" do
        with_tag "div.col-md-6.slab" do
          with_tag :a, with: { href: "/Death_Star?tab=metric" } do
            with_text /12\s*Metric/
          end
        end
        with_tag "div.col-md-6.slab" do
          with_tag :a, with: { href: "/Death_Star?tab=topic" } do
            with_text /1\s*Topics/
          end
        end
      end
    end
  end
end
