RSpec.describe Card::Set::Abstract::Filter do
  let(:card) { Card["Company"].fetch :browse_topic_filter }

  describe "#select_filter_tag" do
    it "renders single select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.select_filter_tag "Topic", nil, options
      expect(html).to have_tag :select, with: { name: "filter[Topic]" }
    end
  end

  describe "#multiselect_filter" do
    it "renders multi select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.multiselect_filter :wikirate_topic, nil, options
      expect(html).to have_tag :select, with: { name: "filter[wikirate_topic][]",
                                                multiple: "multiple" }
    end
  end
end
