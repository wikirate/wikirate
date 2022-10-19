RSpec.describe Card::AnswerQuery do
  include_context "answer query"

  context "with fixed company" do
    let(:default_filters) { { company_id: "Death_Star".card_id, year: :latest } }
    let(:answer_parts) { [1, -1] } # metric and year

    context "and multiple filter conditions" do
      it "policy and bookmark" do
        expect(search(policy: "Evil Dataset", bookmark: :bookmark))
          .to eq(["disturbances in the Force+2001"])
      end

      it "year and industry" do
        Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) do
          expect(search(year: "1991", topic: "Force", bookmark: :bookmark, updated: :week))
            .to eq(with_year("disturbances in the Force", 1991))
        end
      end

      it "all in" do
        Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) do
          expect(search(year: "1992", topic: "Force", bookmark: :bookmark, updated: :month,
                        dataset: "Evil Dataset", research_policy: "Community Assessed",
                        name: "in the", metric_type: "Researched"))
            .to eq(with_year("disturbances in the Force", 1992))
        end
      end
    end
  end
end
