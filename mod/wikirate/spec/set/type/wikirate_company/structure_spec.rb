
RSpec.describe Card::Set::Type::WikirateCompany::Structure do


  describe "details tab" do
    subject { Card["Samsung"].format(:html)._render_details_tab }
    it "has jurisdiction table" do
      is_expected.to have_tag "table" do
        with_tag :tr do
          with_tag :td do
            with_text "Country of Headquarters"
          end
          with_tag :td do
            with_text "Korriban"
          end
        end
      end
    end
  end


  describe "view :browse_item" do
    subject { Card["Death Star"].format(:html)._render_browse_item }
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
            with_text /13\s*Metric/
          end
        end
        with_tag "div.col-md-6.slab" do
          with_tag :a, with: { href: "/Death_Star?tab=topic" } do
            with_text /2\s*Topics/
          end
        end
      end
    end
  end
end
