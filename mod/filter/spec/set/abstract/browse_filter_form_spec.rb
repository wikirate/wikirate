describe Card::Set::Abstract::BrowseFilterForm do
  # define the sample card to use that includes the BrowseFilterForm
  let(:card) { Card["Company"].fetch trait: :browse_topic_filter }

  describe "view :filter_form" do
    subject { card.format.render_filter_form }

    it "has filter widget" do
      is_expected.to have_tag("._filter-widget") do
        with_tag "._add-filter-dropdown" do
          with_tag "a.dropdown-item", text: /Keyword/,
                                      with: { "data-category": "name" }
          with_tag "a.dropdown-item", text: /Metric/,
                                      with: { "data-category": "metric" }
          with_tag "a.dropdown-item", text: /Project/,
                                      with: { "data-category": "project" }
          with_tag "a.dropdown-item", text: /Company/,
                                      with: { "data-category": "wikirate_company" }
        end
      end
    end

    it "has sort field" do
      is_expected.to have_tag(".sort-input-group") do
        with_select "sort", with: { "data-minimum-results-for-search": "Infinity" } do
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
