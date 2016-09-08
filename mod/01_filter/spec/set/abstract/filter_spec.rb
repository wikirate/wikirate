describe Card::Set::Abstract::Filter do
  # define the sample card to use
  let(:card) { Card["Company"].fetch trait: :filter_search_topic }

  describe "html format" do
    it "#advance_formgroups" do
      advanced_keys = %w(metric project wikirate_company)
      advanced_keys = card.format.append_formgroup advanced_keys
      html =
        card.format.advance_formgroups advance_formgroups: advanced_keys
      expect(html).to have_tag(:div, with: { class: "advanced-options" }) do
        with_tag :div, with: { id: "collapseFilter", class: "collapse" } do
          with_tag :label, text: "Metric"
          with_tag :div, with: { class: "editor" } do
            with_tag :select, with: { class: "pointer-select", id: "metric" }
          end
          with_tag :label, text: "Project"
          with_tag :div, with: { class: "editor" } do
            with_tag :select, with: { class: "pointer-select", id: "project" }
          end
          with_tag :label, text: "Company"
          with_tag :div, with: { class: "editor" } do
            with_tag :select, with: { class: "pointer-select",
                                      id: "wikirate_company" }
          end
        end
      end
    end
    it "renders view: filter_form" do
      # card.stub(:default_keys).and_return(all_filter_fields)
      html = card.format.render_filter_form
      expect(html).to have_tag(:form) do
        with_tag :div, with: { class: "form-group filter-input",
                               card_name: "Company+filter search topic" } do
          with_tag :label, text: "Sort"
          with_tag :div do
            with_tag :div, with: { class: "editor" } do
              with_tag :select, with: { name: "sort" }
            end
          end
          with_tag :div do
            with_tag :div, with: { class: "editor" } do
              with_tag :input, with: { type: "text", name: "name" }
            end
          end
          with_tag :div, with: { class: "advanced-options" }
        end
      end
    end
    it "renders view sort_formgroup" do
      html = card.format.render_sort_formgroup
      expect(html).to have_tag(:div,
                               with: { class: "form-group filter-input" }) do
        with_tag :label, text: "Sort"
        with_tag :div do
          with_tag :div, with: { class: "editor" } do
            with_tag :select, with: { name: "sort" } do
              with_tag :option, with: { selected: "selected", value: "metric" },
                                text: "Most Metrics"
              with_tag :option, with: { value: "company" },
                                text: "Most Companies"
            end
          end
        end
      end
    end
    it "renders view industry_formgroup" do
      html = card.format.render_industry_formgroup

      industries = Card[card.industry_metric_name].value_options
      expect(html).to have_tag(:div,
                               with: { class: "form-group filter-input" }) do
        with_tag :label, text: "Industry"
        with_tag :select, with: { name: "industry", class: "pointer-select" } do
          industries.each do |i|
            with_tag :option, with: { value: i }, text: i
          end
          with_tag :option, with: { value: "" }, text: "--"
        end
      end
    end
    it "renders view importance_formgroup" do
      html = card.format.render_importance_formgroup
    end
    it "renders view designer_formgroup" do
      html = card.format.render_designer_formgroup
    end
    it "renders view metric_value_formgroup" do
      html = card.format.render_metric_value_formgroup
    end
    it "renders view research_policy_formgroup" do
      html = card.format.render_research_policy_formgroup
    end
    it "renders view metric_type_formgroup" do
      html = card.format.render_metric_type_formgroup
    end
    it "renders view name_formgroup" do
      html = card.format.render_name_formgroup
    end
    describe "#multiselect_filter" do

    end
    describe "#simple_multiselect_filter" do

    end
    describe "#select_filter_html" do

    end
    describe "#simple_select_filter" do

    end
    describe "#select_filter" do

    end
    describe "#type_options" do

    end
    describe "#text_filter" do

    end
  end
end
