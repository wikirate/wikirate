RSpec.describe Card::Set::Type::MetricValue::TableRow do
  describe "#company_details_sidebar" do
    subject { metric_value.format(:html)._render_company_details_sidebar }

    let(:metric_value) { sample_metric_value }
    let(:company_name) { metric_value.company }

    it "has close icon" do
      is_expected.to have_tag "div.details-close-icon" do
        with_tag :i, with: { class: "fa-times-circle" }
      end
    end
    it "renders header row with links" do
      is_expected.to have_tag "div.row.clearfix" do
        with_tag "div.company-logo" do
          with_tag "a.inherit-anchor", with: { href: "/#{company_name}" }
        end
        with_tag "div.company-name" do
          with_tag "a.inherit-anchor", with: { href: "/#{company_name}" } do
            with_text "Death Star"
          end
        end
      end
    end
    it "renders metric details" do
    end
    it "renders discussion" do
    end
  end
end
