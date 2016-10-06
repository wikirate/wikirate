describe Card::Set::Abstract::Filter do
  # define the sample card to use
  let(:card) { Card["Company"].fetch trait: :filter_search_topic }

  describe "html format" do
    it "#advanced_formgroups" do
      advanced_keys = %w(metric project wikirate_company)
      advanced_keys = card.format.append_formgroup advanced_keys
      html =
        card.format.advanced_formgroups advanced_formgroups: advanced_keys
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
    it "renders view designer_formgroup" do
      Card.create! name: "Jedi+disturbances in the Force+Joe Admin",
                   type_id: Card::MetricID
      html = card.format.render_designer_formgroup
      # ensure score metric is return the third part as designer name
      expect(html).to have_tag(:option, with: { value: "Joe Admin" },
                                        text: "Joe Admin")
    end
    describe "view research_policy_formgroup" do
      context "select form" do
        it "renders select list" do
          html = card.format.render_research_policy_formgroup select_list: true
          expect(html).to have_tag(:select, with: { name: "research_policy" })
        end
      end
      context "checkbox form" do
        it "renders checkboxes" do
          Card.create name: "sidan", type_id: Card::ResearchPolicyID
          html = card.format.render_research_policy_formgroup
          expect(html).to have_tag(:input, with: { name: "research_policy[]" })
        end
      end
    end
    describe "view metric_type_formgroup" do
      context "select form" do
        it "renders select list" do
          html = card.format.render_metric_type_formgroup select_list: true
          expect(html).to have_tag(:select, with: { name: "metric_type" })
        end
      end
      context "checkbox form" do
        it "renders checkboxes" do
          html = card.format.render_metric_type_formgroup
          expect(html).to have_tag(:input, with: { name: "type[]" })
        end
      end
    end
    it "renders view name_formgroup" do
      # predefined name
      html = card.format.render_name_formgroup name: "SiDan"
      expect(html).to have_tag(:input, with: { name: "SiDan" })
      # pre-defined title
      html = card.format.render_name_formgroup title: "SiDan"
      expect(html).to have_tag(:label, text: "SiDan")
    end
    describe "#checkbox_formgroup" do
      it "renders checkboxes" do
        options = %w(Fancy A hTc Phone?)
        html = card.format.checkbox_filter "test", options, "htc"
        expect(html).to have_tag(:div, with: { class: "form-group" }) do
          with_tag :label, text: "test"
          with_tag :div, with: { class: "editor" } do
            options.each do |opt|
              with_tag :input, with: { type: "checkbox", name: "test[]",
                                       value: opt.downcase }
            end
            with_tag :input, with: { type: "checkbox", name: "test[]",
                                     value: "htc", checked: "checked" }
          end
        end
      end
    end
    describe "#simple_multiselect_filter" do
      it "renders multi select list" do
        options = card.format.type_options :wikirate_topic
        html = card.format.simple_multiselect_filter "Topic", options,
                                                     nil, "Sidan"
        expect(html).to have_tag(:div, with: { class: "form-group Topic" }) do
          with_tag :label, text: "Sidan"
          with_tag :select, with: { name: "Topic[]", multiple: "multiple" }
        end
      end
    end
    describe "#multiselect_filter" do
      it "renders multi select list" do
        html = card.format.multiselect_filter :wikirate_topic, "Whatever"
        expect(html).to have_tag(:div, with: { class: "wikirate_topic" }) do
          with_tag :label, text: "Whatever"
          with_tag :select, with: { name: "wikirate_topic[]",
                                    multiple: "multiple" }
        end
      end
    end
    describe "#select_filter_html" do
      it "renders single select list" do
        options = card.format.type_options :wikirate_topic
        html = card.format.select_filter_html "Topic", options, nil, "Sidan"
        expect(html).to have_tag(:div, with: { class: "form-group" }) do
          with_tag :label, text: "Sidan"
          with_tag :select, with: { name: "Topic" }
        end
      end
    end
    describe "#select_filter" do
      it "renders single select list" do
        options = card.format.select_filter :wikirate_topic, "asc"
        html = card.format.select_filter_html "Topic", options, nil, "Sidan"
        expect(html).to have_tag(:div, with: { class: "form-group" }) do
          with_tag :label, text: "Sidan"
          with_tag :select, with: { name: "Topic" }
        end
      end
    end
  end
end
