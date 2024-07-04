RSpec.describe Card::Set::Abstract::Filter do
  let(:card) { :wikirate_topic.card }

  describe "#select_filter" do
    it "renders single select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.send :select_filter, "Topic", options: options
      expect(html).to have_tag :select, with: { name: "filter[Topic]" }
    end
  end

  describe "#multiselect_filter" do
    it "renders multi select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.send :multiselect_filter, :wikirate_topic, options: options
      expect(html).to have_tag :select, with: { name: "filter[wikirate_topic][]",
                                                multiple: "multiple" }
    end
  end
end
