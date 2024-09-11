RSpec.describe Card::Set::Abstract::Filter do
  let(:card) { :topic.card }

  describe "#select_filter" do
    it "renders single select list" do
      options = card.format.type_options :topic
      html = card.format.send :select_filter, "Topic", options: options
      expect(html).to have_tag :select, with: { name: "filter[Topic]" }
    end
  end

  describe "#multiselect_filter" do
    it "renders multi select list" do
      options = card.format.type_options :topic
      html = card.format.send :multiselect_filter, :topic, options: options
      expect(html).to have_tag :select, with: { name: "filter[topic][]",
                                                multiple: "multiple" }
    end
  end
end
