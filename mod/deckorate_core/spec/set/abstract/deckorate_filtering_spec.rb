describe Card::Set::Abstract::DeckorateFiltering do
  # define the sample card to use that includes the DeckorateFiltering
  let(:card) { :topic.card }

  describe "view :filter_form" do
    subject { card.format.render_compact_filter_form }

    it "has filter widget" do
      is_expected.to have_tag("._compact-filter") do
        with_tag "._add-filter-dropdown" do
          with_tag "a.dropdown-item", text: /Name/,
                                      with: { "data-category": "name" }
        end
      end
    end

    it "has sort field" do
      is_expected.to have_tag(".sort-input-group") do
        with_select "sort_by", with: { "data-minimum-results-for-search": "Infinity" } do
          with_option "Alphabetical", "name"
          with_option "Most Metrics", "metric"
          with_option "Most Companies", "company"
        end
      end
    end
  end

  describe "view :content" do
    subject { card.format.render_content }

    it "has slot with filter-result-slot class" do
      is_expected.to have_tag(".card-slot._filter-result-slot")
    end
  end
end
