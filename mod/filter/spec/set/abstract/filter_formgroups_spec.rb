describe Card::Set::Abstract::FilterFormgroups do
  let(:card) { Card["Company"].fetch trait: :browse_topic_filter }

  describe "sort formgroup" do
    subject { card.format.render_sort_formgroup }

    it "renders select form" do
      is_expected.to have_tag(:div,
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
  end

  describe "industry formgroup" do
    subject { card.format.render_industry_formgroup }

    it "renders select form" do
      industries =
        Card[Card::CompanyFilterQuery::INDUSTRY_METRIC_NAME].value_options
      is_expected.to have_tag(:div,
                              with: { class: "form-group filter-input" }) do
        with_tag :label, text: "Industry"
        with_tag :select,
                 with: { name: "filter[industry]", class: "pointer-select" } do
          industries.each do |i|
            with_tag :option, with: { value: i }, text: i
          end
          with_tag :option, with: { value: "" }, text: "--"
        end
      end
    end
  end
  describe "designer formgroup" do
    it "renders option form" do
      Card.create! name: "Jedi+disturbances in the Force+Joe Admin",
                   type_id: Card::MetricID
      html = card.format.render_designer_formgroup
      # ensure score metric is return the third part as designer name
      expect(html).to have_tag(:option, with: { value: "Joe Admin" },
                                        text: "Joe Admin")
    end
  end

  describe "research_policy formgroup" do
    context "select form" do
      subject { card.format.research_policy_select }

      it "renders select list" do
        is_expected.to have_tag(
          :select, with: { name: "filter[research_policy]" }
        )
      end
    end
    context "checkbox form" do
      subject { card.format.render_research_policy_formgroup }

      it "renders checkboxes" do
        is_expected.to have_tag(
          :input, with: { name: "filter[research_policy][]" }
        )
      end
    end
  end

  describe "metric_type formgroup" do
    context "select form" do
      subject { card.format.metric_type_select }

      it "renders select list" do
        is_expected.to have_tag(:select, with: { name: "filter[metric_type]" })
      end
    end
    context "checkbox form" do
      subject { card.format.render_metric_type_formgroup }

      it "renders checkboxes" do
        is_expected.to have_tag(:input, with: { name: "filter[metric_type][]" })
      end
    end
  end
  describe "name formgroup" do
    subject { card.format.render_name_formgroup }

    it "renders input tag" do
      is_expected.to have_tag(:input, with: { name: "filter[name]" })
    end
  end
end
