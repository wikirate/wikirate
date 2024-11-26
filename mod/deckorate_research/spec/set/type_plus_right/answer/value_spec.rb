
RSpec.describe Card::Set::TypePlusRight::Answer::Value do
  let(:metric) do
    sample_metric.tap do |m|
      Card::Auth.as_bot do
        m.update! subcards: { "+Unit" => { content: "Imperial military units",
                                           type_id: Card::PhraseID } }
      end
    end
  end

  let(:company) { sample_company }

  let(:answer) do
    subcards = {
      "+metric"  => { content: metric.name },
      "+company" => { content: "[[#{company.name}]]",
                      type_id: Card::PointerID },
      "+value"   => { content: "I'm fine, I'm just not happy.",
                      type_id: Card::FreeTextValueID },
      "+year"    => { content: "2015",
                      type_id: Card::PointerID },
      "+source"  => { content: :star_wars_source.cardname,
                      type_id: Card::PointerID }
    }
    Card::Auth.as_bot do
      Card.create! type_id: Card::AnswerID, subcards: subcards
    end
  end

  def value_card
    answer.fetch(:value)
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
      ::Answer.where(metric_id: "#{metric}+#{scorer}".card_id,
                     company_id: company.card_id,
                     year: year.to_i)
              .take.value
    end

    it "updates related score" do
      expect(scored_value).to eq "10.0"
      Card[researched_value_name].update! content: "no"
      expect(scored_value).to eq "0.0"
    end

    it "standardizes unknown" do
      answer = sample_answer
      answer.value_card.update! content: "uNkNoWn"
      expect(answer.value).to eq("Unknown")
    end
  end
end
