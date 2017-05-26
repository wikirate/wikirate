describe Card::Set::Abstract::BrowseFilterForm do
  # define the sample card to use
  # let(:card) { Card["Company"].fetch trait: :metric_company_filter }

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
      expect(html).to have_tag(:form) do
        with_tag :div, with: { class: "form-group filter-input",
                               card_name: "Company+browse topic filter" } do
          with_tag :label, text: "Sort"
          with_tag :div do
            with_tag :div, with: { class: "editor" } do
              with_tag :select, with: { name: "sort" }
            end
          end
          with_tag :div do
            with_tag :div, with: { class: "editor" } do
              with_tag :input, with: { type: "text", name: "filter[name]" }
            end
          end
        end
        with_tag :div, with: { class: "advanced-options" }
      end
    end
  end
  context "render core view" do
    subject { card.format.render_core }

    let(:content_view) { card.format.content_view }

    it "has frame" do
      # log_html subject
      # is_expected.to have_tag(:form, with: { class: "filter-container",
      #                                        action: "/Company?view=#{content_view}"}) do
      #   with_tag :div, with: { class: "filter-header" } do
      #     # with_tag :span, with: { class: "glyphicon glyphicon-filter" }
      #     with_tag :div, with: { class: "filter-details collapse" }
      #   end
      # end
    end
    # it "has formgroups" do
    #   is_expected.to have_tag :form, with: { action: "/Company?view=#{content_view}" } do
    #     with_tag :h4, text: "Company"
    #     with_tag :div, with: { class: "form-group filter-input" } do
    #       with_tag :label, text: "Keyword"
    #       with_tag :input, with: { type: "text", name: "filter[name]" }
    #     end
    #     with_tag :div, with: { class: "form-group filter-input" } do
    #       with_tag :label, text: "Industry"
    #       with_tag :select, with: { name: "filter[industry]" }
    #     end
    #     with_tag :div, with: { class: "form-group filter-input" } do
    #       with_tag :label, text: "Project"
    #       with_tag :select, with: { name: "filter[project]" }
    #     end
    #     with_tag :div, with: { class: "form-group filter-input" } do
    #       with_tag :label, text: "Year"
    #       with_tag :select, with: { name: "filter[year]" }
    #     end
    #     with_tag :div, with: { class: "form-group filter-input" } do
    #       with_tag :label, text: "Value"
    #       with_tag :select, with: { name: "filter[value]" }
    #     end
    #     with_tag :a, with: { href: "/Company?view=content_left_col" },
    #                  text: "Reset"
    #     with_tag :button, with: { name: "button", type: "submit" },
    #                       text: "Filter"
    #   end
    # end
  end

  context "Fields are filled" do
    # it "expand the form" do
    #   Card::Env.params["company"] = "Apple Inc"
    #   html = card.format.render_core
    #   expect(html).to have_tag :div, with: { class: "filter-details",
    #                                          style: "display: block;" }
    # end
  end
end
