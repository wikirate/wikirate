
RSpec.describe Card::Set::Type::WikirateTopic::Structure do
  extend Card::SpecHelper::ViewHelper::ViewDescriber

  let(:topic) { Card["Force"] }

  describe_views :open_content, :listing, :edit, :homepage_item,
                 :details_tab, :wikirate_company_tab, :post_tab, :project_tab do
    it "has no errors" do
      expect(topic.format.render(view)).to lack_errors
    end
  end

  describe "view :browse_item" do
    subject { topic.format(:html)._render_browse_item }

    it "has topic title" do
      is_expected.to have_tag "div.topic-header" do
        with_text "Force"
      end
    end

    it "has image link" do
      is_expected.to have_tag "div.company-content" do
        with_tag :a, with: { href: "http://wikirate.org/Force" } do
          with_tag :img
        end
      end
    end

    it "has counts with tab links" do
      is_expected.to have_tag "div.row.data-count" do
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
