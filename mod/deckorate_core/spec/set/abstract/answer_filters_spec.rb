describe Card::Set::Abstract::AnswerFilters do
  let(:filter_card) { :topic.card }

  context "with topic filter card" do
    describe "filter_sort_dropdown" do
      subject { filter_card.format.render_filter_sort_dropdown }

      it "renders select form" do
        is_expected.to have_tag :select, with: { name: "sort_by" } do
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

      def with_check_option binding, type, value
        binding.with_tag("div") do
          with_tag "label", text: value
          with_tag "input", type: type, value: value
        end
      end

      describe "assessment filter" do
        let(:filter_type) { :assessment }

        specify do
          is_expected.to have_tag("div.filter-radio-list") do
            with_check_option self, "radio", "Community Assessed"
            with_check_option self, "radio", "Steward Assessed"
          end
        end
      end

      describe "metric_type filter" do
        let(:filter_type) { :metric_type }

        specify do
          is_expected.to have_tag("div.filter-check-list") do
            with_check_option self, "checkbox", "Researched"
            with_check_option self, "checkbox", "Formula"
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

      describe "assessment filter" do
        let(:filter_type) { :assessment }

        specify do
          is_expected.to have_tag(:select, with: { name: "filter[assessment]" }) do
            with_option "Community Assessed", "Community Assessed"
            with_option "Steward Assessed", "Steward Assessed"
          end
        end
      end

      describe "metric_type filter" do
        let(:filter_type) { :metric_type }

        specify do
          is_expected.to have_tag :select, with: { multiple: "multiple" } do
            with_option "Researched"
            with_option "Formula"
            with_option "Rating"
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
