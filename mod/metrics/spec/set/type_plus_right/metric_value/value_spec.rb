
describe Card::Set::TypePlusRight::MetricValue::Value do
  before do
    login_as "joe_user"
    @metric = sample_metric
    @metric.update_attributes! subcards:
      { "+Unit" => { content: "Imperial military units",
                     type_id: Card::PhraseID } }
    @company = sample_company
    subcards = {
      "+metric"  => { content: @metric.name },
      "+company" => { content: "[[#{@company.name}]]",
                      type_id: Card::PointerID },
      "+value"   => { content: "I'm fine, I'm just not happy.",
                      type_id: Card::PhraseID },
      "+year"    => { content: "2015",
                      type_id: Card::PointerID },
      "+source"  => { subcards: { "new source" => { "+Link" =>
                      { content: "http://www.google.com/?q=everybodylies",
                        type_id: Card::PhraseID } } } }
    }
    @metric_value = Card.create! type_id: Card::MetricValueID,
                                 subcards: subcards
    @card = @metric_value.fetch trait: :value
  end

  describe "#metric" do
    subject { @metric_value.fetch(trait: :value).metric }

    it { is_expected.to eq @metric.name }
  end

  describe "#company" do
    subject { @metric_value.fetch(trait: :value).company }

    it { is_expected.to eq @company.name }
  end

  describe "#year" do
    subject { @metric_value.fetch(trait: :value).year }

    it { is_expected.to eq "2015" }
  end

  context "when updated" do
    METRIC = "Jedi+disturbances in the Force"
    SCORER =  "Joe User"
    COMPANY = "Death Star"
    YEAR = "1977"
    let(:researched_value_name) { "#{METRIC}+#{COMPANY}+#{YEAR}+value" }
    let(:scored_value_name) { "#{METRIC}+#{SCORER}+#{COMPANY}+#{YEAR}+value" }

    it "updates related score" do
      expect(Card[scored_value_name].content).to eq "10"
      Card[researched_value_name].update_attributes! content: "no"
      expect(Card[scored_value_name].content).to eq "0"
    end
  end
end
