RSpec.describe Card::Set::Type::Metric::Structure do
  let(:metric) { Card["Jedi+disturbances in the Force"] }

  %i[open_content listing edit homepage_item
     details_tab score_tab source_tab project_tab].each do |view|
    describe "view: #{view}" do
      it "has no errors" do
        expect(metric.format.render(view)).to lack_errors
      end
    end
  end

  describe "view :browse_item" do
    subject { metric.format(:html)._render_browse_item }

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
