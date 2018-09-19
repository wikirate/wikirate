describe Card::Set::TypePlusRight::MetricAnswer::Source do
  let(:metric) { sample_metric }
  let(:company) { sample_company }
  let(:metric_answer_name) { "#{metric.name}+#{company.name}+2015" }

  describe "+new value" do
    it "has source preview area" do
      core = view :core, card: { name: "#{metric.name}+#{company.name}+new value" }
      expect(core).to have_tag("div#source_preview_main")
    end
  end

  describe "edit view" do
    it "shows sourcebox source editor while the source is a real card" do
      subcard = {
        "+metric" => { "content" => metric.name },
        "+company" => { "content" => "[[#{company.name}]]",
                        :type_id => Card::PointerID },
        "+value" => { "content" => "10", :type_id => metric.value_cardtype_id },
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
      metric_answer = create metric_answer_name,
                             type_id: Card::MetricAnswerID, subcards: subcard
      source = metric_answer.fetch trait: :source
      expect(view(:edit, card: source)).to have_tag("div.sourcebox" ) do
        with_tag("input#sourcebox")
        with_tag("button", with: { name: "button" })
      end
    end
  end
end
