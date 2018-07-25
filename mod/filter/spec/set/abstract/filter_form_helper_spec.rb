describe Card::Set::Abstract::FilterFormHelper do
  let(:card) { Card["Company"].fetch trait: :browse_topic_filter }

  describe "#select_filter_tag" do
    it "renders single select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.select_filter_tag "Topic", nil, options
      expect(html).to have_tag :select, with: { name: "filter[Topic]" }
    end
  end

  describe "#select_filter_type_based" do
    it "renders single select list" do
      html = card.format.select_filter_type_based :wikirate_topic
      expect(html).to have_tag :select, with: { name: "filter[wikirate_topic]" }
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

  describe "#multiselect_filter_type_based" do
    subject { card.format.multiselect_filter_type_based :wikirate_topic }

    it "renders multi select list" do
      is_expected.to have_tag :select, with: { name: "filter[wikirate_topic][]",
                                               multiple: "multiple" }
    end
  end
end
