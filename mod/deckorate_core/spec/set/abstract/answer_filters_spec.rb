describe Card::Set::Abstract::AnswerFilters do
  let(:filter_card) { :wikirate_topic.card }

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

  context "with metric filter card" do
    let(:filter_card) { Card[:metric] }

    describe "designer filter" do
      it "renders option form" do
        Card.create! name: "Jedi+disturbances in the Force+Joe Admin",
                     type_id: Card::MetricID
        html = filter_card.format.filter_input_field :designer
        # ensure score metric is return the third part as designer name
        expect(html).to have_tag(:option, with: { value: "Joe Admin" },
                                          text: "Joe Admin")
      end
    end

    describe "research_policy filter" do
      subject { filter_card.format.filter_input_field :research_policy }

      it "render multiselect list" do
        is_expected.to have_tag(:select, with: { name: "filter[research_policy]" }) do
          with_option "Community Assessed", "Community Assessed"
          with_option "Designer Assessed", "Designer Assessed"
        end
      end
    end

    describe "metric_type filter" do
      context "multiselect form" do
        subject { filter_card.format.filter_input_field :metric_type }

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

  describe "name filter" do
    subject { filter_card.format.filter_input_field :name }

    it "renders input tag" do
      is_expected.to have_tag(:input, with: { name: "filter[name]" })
    end
  end
end
