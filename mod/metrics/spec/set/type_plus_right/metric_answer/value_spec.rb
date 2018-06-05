
RSpec.describe Card::Set::TypePlusRight::MetricAnswer::Value do
  let(:metric) do
    m = sample_metric
    Card::Auth.as_bot do
      m.update_attributes! subcards:
            { "+Unit" => { content: "Imperial military units",
                           type_id: Card::PhraseID } }
    end
    m
  end

  let(:company) { sample_company }

  let(:metric_answer) do
    subcards = {
      "+metric"  => { content: metric.name },
      "+company" => { content: "[[#{company.name}]]",
                      type_id: Card::PointerID },
      "+value"   => { content: "I'm fine, I'm just not happy.",
                      type_id: Card::PhraseID },
      "+year"    => { content: "2015",
                      type_id: Card::PointerID },
      "+source"  => { subcards: { "new source" => { "+Link" =>
                      { content: "http://www.google.com/?q=everybodylies",
                        type_id: Card::PhraseID } } } }
    }
    Card::Auth.as_bot do
      Card.create! type_id: Card::MetricAnswerID, subcards: subcards
    end
  end

  def value_card
    metric_answer.fetch(trait: :value)
  end

  specify "#metric" do
    expect(value_card.metric).to eq metric.name
  end

  specify "#company" do
    expect(value_card.company).to eq company.name
  end

  specify "#year" do
    expect(value_card.year).to eq "2015"
  end

  context "when updated" do
    let(:metric) { "Jedi+disturbances in the Force" }
    let(:scorer) { "Joe User" }
    let(:company) { "Death Star" }
    let(:year) { "1977" }

    let(:researched_value_name) { "#{metric}+#{company}+#{year}+value" }
    let(:scored_value_name) { "#{metric}+#{scorer}+#{company}+#{year}+value" }

    def scored_value
      Answer.where(metric_name: "#{metric}+#{scorer}", company_name: company,
                   year: year.to_i)
            .take.value
    end

    it "updates related score" do
      expect(scored_value).to eq "10.0"
      Card[researched_value_name].update_attributes! content: "no"
      expect(scored_value).to eq "0.0"
    end
  end
end
