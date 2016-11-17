describe Card::Set::Abstract::FilterFormHelper do
  let(:card) { Card["Company"].fetch trait: :browse_topic_filter }
  describe "#simple_multiselect_filter" do
    it "renders multi select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.multiselect_filter "Topic", options,
                                            nil, "Sidan"
      expect(html).to have_tag(:div, with: { class: "form-group Topic" }) do
        with_tag :label, text: "Sidan"
        with_tag :select, with: { name: "filter[Topic][]", multiple: "multiple" }
      end
    end
  end
  describe "#multiselect_filter" do
    it "renders multi select list" do
      html = card.format.multiselect_filter_type_based :wikirate_topic, "Whatever"
      expect(html).to have_tag(:div, with: { class: "wikirate_topic" }) do
        with_tag :label, text: "Whatever"
        with_tag :select, with: { name: "filter[wikirate_topic][]",
                                  multiple: "multiple" }
      end
    end
  end
  describe "#select_filter_tag" do
    it "renders single select list" do
      options = card.format.type_options :wikirate_topic
      html = card.format.select_filter_tag "Topic", options, nil, "Sidan"
      expect(html).to have_tag(:div, with: { class: "form-group" }) do
        with_tag :label, text: "Sidan"
        with_tag :select, with: { name: "filter[Topic]" }
      end
    end
  end
  describe "#select_filter" do
    it "renders single select list" do
      options = card.format.select_filter_type_based :wikirate_topic, "asc"
      html = card.format.select_filter_tag "Topic", options, nil, "Sidan"
      expect(html).to have_tag(:div, with: { class: "form-group" }) do
        with_tag :label, text: "Sidan"
        with_tag :select, with: { name: "filter[Topic]" }
      end
    end
  end

  describe "#checkbox_filter" do
    it "renders checkboxes" do
      options = %w(Fancy A hTc Phone?)
      html = card.format.checkbox_filter "test", "Test", "htc", options
      expect(html).to have_tag(:div, with: { class: "form-group" }) do
        with_tag :label, text: "Test"
        with_tag :div, with: { class: "editor" } do
          options.each do |opt|
            with_tag :input, with: { type: "checkbox", name: "filter[test][]",
                                     value: opt.downcase }
          end
          with_tag :input, with: { type: "checkbox", name: "filter[test][]",
                                   value: "htc", checked: "checked" }
        end
      end
    end
  end
end
