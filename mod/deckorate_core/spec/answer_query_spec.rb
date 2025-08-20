RSpec.describe Card::AnswerQuery do
  include_context "answer query"

  context "with combined filters" do
    context "with fixed company" do
      let(:default_filters) { { company_id: "Death_Star".card_id, year: :latest } }
      let(:answer_parts) { [1, -1] } # metric and year

      specify "policy and bookmark" do
        expect(search(policy: "Evil Dataset", bookmark: :bookmark))
          .to eq(["disturbances in the Force+2001"])
      end

      specify "year, topic, bookmark, and updated" do
        Timecop.freeze(Deckorate::HAPPY_BIRTHDAY) do
          expect(
            search(year: "1991", topic: %i[esg_topics environment].cardname, bookmark: :bookmark, updated: :week)
          ).to eq(with_year("disturbances in the Force", 1991))
        end
      end

      specify "all in" do
        Timecop.freeze(Deckorate::HAPPY_BIRTHDAY) do
          expect(
            search(year: "1992", topic: %i[esg_topics environment].cardname, bookmark: :bookmark, updated: :month,
                   dataset: "Evil Dataset", assessment: "Community Assessed",
                   name: "in the", metric_type: "Researched")
          ).to eq(with_year("disturbances in the Force", 1992))
        end
      end
    end

    context "with fixed metric" do
      let(:metric_name) { "Jedi+disturbances in the Force" }
      let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
      let(:answer_parts) { [-2, -1] }
      let(:default_sort) { {} }

      specify "dataset and company_category" do
        expect(search(dataset: "Evil Dataset", company_category: "A").sort)
          .to eq(["Death Star+2001", "SPECTRE+2000"])
      end

      specify "year and company_category" do
        expect(search(year: "1977", company_category: "A"))
          .to eq(with_year("Death Star", 1977))
      end

      specify "all in" do
        Timecop.freeze(Deckorate::HAPPY_BIRTHDAY) do
          expect(search(year: "1990",
                        company_category: "A",
                        dataset: "Evil Dataset",
                        updated: :today,
                        name: "star"))
            .to eq(with_year("Death Star", 1990))
        end
      end
    end
  end
end
