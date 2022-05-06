describe Card::Set::Abstract::AnswerFilters do
  let(:filter_card) { :wikirate_topic.card }

  context "with topic filter card" do
    describe "filter_sort_dropdown" do
      subject { filter_card.format.render_filter_sort_dropdown }

      it "renders select form" do
        is_expected.to have_tag :select, with: { name: "sort" } do
          with_option "Most Bookmarked", "bookmarkers" # , selected: "selected"
          with_option "Most Metrics", "metric"
          with_option "Most Companies", "company"
        end
      end
    end
  end

  context "with metric filter card" do
    let(:filter_card) { Card[:metric] }

    context "with full (not compact) filters" do
      subject { filter_card.format.filter_input_field filter_type }

      describe "research_policy filter" do
        let(:filter_type) { :research_policy }

        specify do
          is_expected.to have_tag("div.filter-radio-list") do
            with_tag("div.filter-radio-item") do
              with_tag "label", text: "Community Assessed"
              with_tag "input", type: "radio", value: "Community Assessed"
            end

            with_tag("div.filter-radio-item") do
              with_tag "label", text: "Designer Assessed"
              with_tag "input", type: "radio", value: "Designer Assessed"
            end
          end
        end
      end

      describe "metric_type filter" do
        let(:filter_type) { :metric_type }

        specify do
          is_expected.to have_tag("div.filter-check-list") do
            with_tag("div.filter-check-item") do
              with_tag "label", text: "Researched"
              with_tag "input", type: "checkbox", value: "Researched"
            end

            with_tag("div.filter-check-item") do
              with_tag "label", text: "Formula"
              with_tag "input", type: "checkbox", value: "Formula"
            end
          end
        end
      end

      describe "name filter" do
        let(:filter_type) { :name }

        specify { is_expected.to have_tag(:input, with: { name: "filter[name]" }) }
      end
    end

    context "with compact filters" do
      subject { filter_card.format.filter_input_field filter_type, compact: true }

      describe "designer filter" do
        let(:filter_type) { :designer }

        specify do
          is_expected.to have_tag(:option, with: { value: "Jedi" }, text: "Jedi")
        end
      end

      describe "research_policy filter" do
        let(:filter_type) { :research_policy }

        specify do
          is_expected.to have_tag(:select, with: { name: "filter[research_policy]" }) do
            with_option "Community Assessed", "Community Assessed"
            with_option "Designer Assessed", "Designer Assessed"
          end
        end
      end

      describe "metric_type filter" do
        let(:filter_type) { :metric_type }

        specify do
          is_expected.to have_tag :select, with: { multiple: "multiple" } do
            with_option "Researched"
            with_option "Formula"
            with_option "WikiRating"
          end
        end
      end

      describe "name filter" do
        let(:filter_type) { :name }

        specify { is_expected.to have_tag(:input, with: { name: "filter[name]" }) }
      end
    end
  end
end
