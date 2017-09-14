RSpec.describe Card::Set::Type::Metric::Structure do
  subject { Card["Jedi+disturbances in the Force"].format(:html)._render_browse_item }

  describe "view :browse_item" do
    it "has metric title" do
      is_expected.to have_tag "div.name" do
        with_text "disturbances in the Force"
      end
    end

    it "has designer link" do
      is_expected.to have_tag "div.row-data.ellipsis.rating-designer" do
        with_tag :a, with: { href: "Jedi" } do
          with_text /Jedi/
        end
      end
    end

    it "has counts" do
      is_expected.to have_tag "div.row.data-count" do
        with_tag "div.col-md-6.slab" do
          with_text /4\s*Companies/
        end
        with_tag "div.col-md-6.slab" do
          with_text /1\s*Topics/
        end
      end
    end
  end
end
