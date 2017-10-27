describe Card::Set::Abstract::BrowseFilterForm do
  # define the sample card to use
  # let(:card) { Card["Company"].fetch trait: :metric_company_filter }
  let(:card) { Card["Company"].fetch trait: :browse_topic_filter }

  describe "html format" do
    let(:card) { Card["Company"].fetch trait: :browse_topic_filter }

    it "#advanced_formgroups" do
      card.stub(:advanced_filter_keys) { %w[metric project wikirate_company] }
      html =
        card.format.advanced_filter_formgroups
      expect(html).to have_tag(:div, with: { class: "advanced-options" }) do
        with_tag :div, with: { id: "collapseFilter", class: "collapse" } do
          with_tag :label, text: "Metric"
          with_tag :div, with: { class: "editor" } do
            with_tag :input, with: { class: "metric_autocomplete", id: "filter_metric" }
          end
          with_tag :label, text: "Project"
          with_tag :div, with: { class: "editor" } do
            with_tag :select, with: { class: "pointer-select", id: "filter_project" }
          end
          with_tag :label, text: "Company"
          with_tag :div, with: { class: "editor" } do
            with_tag :input, with: { class: "wikirate_company_autocomplete",
                                     id: "filter_wikirate_company" }
          end
        end
      end
    end

    it "renders view: filter_form" do
      # card.stub(:filter_keys).and_return(all_filter_fields)
      html = card.format.render_filter_form
      expect(html).to have_tag("_filter_widget")
    end
  end
  context "render core view" do
    subject { card.format.render_content }

    let(:content_view) { card.format.content_view }

    it "has filter slot" do
      is_expected.to have_tag(".card-slot._filter_result_slot")
    end
  end

  context "Fields are filled" do
    it "expand the form" do
      Card::Env.params["filter"] = { wikirate_company: "Apple Inc" }
      html = card.format.render_core
      expect(html).to have_tag :div, with: { class: "filter-details",
                                             style: "display: block;" }
    end
  end
end
