
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
end
