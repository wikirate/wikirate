describe Card::Set::Abstract::FilterFormgroups do
  let(:filter_card) { Card[:wikirate_company].fetch :browse_topic_filter }

  describe "sort formgroup" do
    subject { filter_card.format.render_sort_formgroup }

    it "renders select form" do
      is_expected.to have_tag :select, with: { name: "sort" } do
        with_option "Most Bookmarked", "bookmarkers" # , selected: "selected"
        with_option "Most Metrics", "metric"
        with_option "Most Companies", "company"
      end
    end
  end

  describe "industry formgroup" do
    subject { filter_card.format.render_filter_industry_formgroup }

    it "renders select form" do
      industries = Card[Card::CompanyFilterQuery::INDUSTRY_METRIC_NAME].value_options
      is_expected.to have_tag :select, with: { name: "filter[industry]",
                                               class: "pointer-select" } do
        industries.each do |text|
          with_option text, text
        end
        with_option "--", ""
      end
    end
  end

  context "with metric filter card" do
    let(:filter_card) { Card[:metric].fetch :browse_metric_filter }

    describe "designer formgroup" do
      it "renders option form" do
        Card.create! name: "Jedi+disturbances in the Force+Joe Admin",
                     type_id: Card::MetricID
        html = filter_card.format.render_filter_designer_formgroup
        # ensure score metric is return the third part as designer name
        expect(html).to have_tag(:option, with: { value: "Joe Admin" },
                                          text: "Joe Admin")
      end
    end

    describe "research_policy formgroup" do
      context "select form" do
        subject { filter_card.format.render_filter_research_policy_formgroup }

        it "renders select list" do
          is_expected.to have_tag(
            :select, with: { name: "filter[research_policy][]" }
          )
        end
      end
      context "multiselect form" do
        subject { filter_card.format.render_filter_research_policy_formgroup }

        it "render multiselect list" do
          is_expected.to have_tag :select, with: { multiple: "multiple" } do
            with_option "Community Assessed", "Community Assessed"
            with_option "Designer Assessed", "Designer Assessed"
          end
        end
      end
    end

    describe "metric_type formgroup" do
      context "multiselect form" do
        subject { filter_card.format.render_filter_metric_type_formgroup }

        it "renders checkboxes" do
          is_expected.to have_tag :select, with: { multiple: "multiple" } do
            with_option "Researched"
            with_option "Formula"
            with_option "WikiRating"
          end
        end
      end
    end
  end

  describe "name formgroup" do
    subject { filter_card.format.render_filter_name_formgroup }

    it "renders input tag" do
      is_expected.to have_tag(:input, with: { name: "filter[name]" })
    end
  end
end
