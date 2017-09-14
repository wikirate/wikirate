describe Card::Set::TypePlusRight::MetricValue::Source do
  before do
    # create a metric value
    @metric = sample_metric
    @company = sample_company
    @metric_value_card_name = "#{@metric.name}+#{@company.name}+2015"
  end

  describe "+new value" do
    it "has source preview area" do
      metric_value_form_card = Card.new(
        name: "#{@metric.name}+#{@company.name}+new value"
      )
      expect(metric_value_form_card.format.render_core).to(
        have_tag("div", with: { id: "source_preview_main" })
      )
    end
  end

  describe "edit view" do
    it "shows sourcebox source editor while the source is a real card" do
      subcard = {
        "+metric" => { "content" => @metric.name },
        "+company" => { "content" => "[[#{@company.name}]]",
                        :type_id => Card::PointerID },
        "+value" => { "content" => "10", :type_id => Card::PhraseID },
        "+year" => { "content" => "2015", :type_id => Card::PointerID },
        "+source" => {
          "subcards" => {
            "new source" => {
              "+Link" => {
                "content" => "http://www.google.com/?q=yo",
                "type_id" => Card::PhraseID
              }
            }
          }
        }
      }
      metric_value = Card.create! name: @metric_value_card_name,
                                  type_id: Card::MetricValueID,
                                  subcards: subcard
      source = metric_value.fetch trait: :source
      html = source.format.render_edit
      expect(html).to have_tag("div", with: { class: "sourcebox" }) do
        with_tag("input", with: { id: "sourcebox" })
        with_tag("button", with: { name: "button" })
      end
    end
  end
end
