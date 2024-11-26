RSpec.describe Card::AnswerQuery::AnswerFilters do
  include_context "answer query"

  context "with fixed company" do
    let(:default_filters) { { company_id: company_name.card_id, year: :latest } }
    let(:answer_parts) { [1, -1] } # metric and year
    let(:company_name) { "Death_Star" }

    specify "#year_query" do
      expect(search(year: "2000"))
        .to eq with_year(["dinosaurlabor", "disturbances in the Force",
                          "disturbances in the Force"], 2000)
    end

    specify "#calculated_query" do
      expect(search(calculated: :calculated))
        .to eq(["darkness rating+1977",
                "deadliness+1977",
                "deadliness+1977",
                "descendant 1+1977",
                "descendant 2+1977",
                "disturbance delta+2001",
                "disturbances in the Force+2001",
                "double friendliness+1977",
                "friendliness+1977",
                "know the unknowns+1977"])
    end

    describe "#updated_by_query" do
      it "finds answer updated by single user" do
        # puts described_class.new(updater: "Joe_User").main_query.to_sql
        expect(query_class.new(updater: "Joe_User").main_query.count).to eq(8)
      end
    end

    describe "#updated_query" do
      let(:answer_parts) { [1] }
      let(:default_filters) { { company_id: company_name.card_id } }

      before { Timecop.freeze Deckorate::HAPPY_BIRTHDAY }
      after { Timecop.return }

      it "finds today's edits" do
        expect(search(updated: :today)).to eq ["disturbances in the Force"]
      end

      it "finds today's edits (hash syntax)" do
        expect(search(updated: { from: :today })).to eq ["disturbances in the Force"]
      end

      it "finds this week's edits" do
        expect(search(updated: :week))
          .to eq ["disturbances in the Force", "disturbances in the Force"]
      end

      # note: "today" means 1 day ago. terminology is a little confusing here..
      it "finds edits with a time range" do
        expect(search(updated: { from: :week, to: :today }))
          .to eq ["disturbances in the Force"]
      end

      it "finds this months's edits" do
        # I added 'metric_type: "Researched"' because the new yaml loading
        # made it so that calculated metrics, including scores, were created before the
        # researched answers, which meant timecop affect the calculation times
        expect(search(updated: :month, metric_type: "Researched"))
          .to eq(["disturbances in the Force"] * 3)
      end
    end
  end

  context "with fixed metric" do
    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    describe "#year_query" do
      specify do
        expect(search(year: "2000"))
          .to eq with_year(["Death Star", "Monster Inc",  "SPECTRE"], 2000)
      end
    end

    describe "#updated_query" do
      before { Timecop.freeze(Deckorate::HAPPY_BIRTHDAY) }
      after { Timecop.return }

      it "finds today's edits" do
        expect(search(updated: :today, year: nil)).to eq(["Death Star+1990"])
      end

      it "finds this week's edits" do
        expect(search(updated: :week, year: nil))
          .to eq ["Death Star+1990", "Death Star+1991"]
      end

      it "finds this months's edits" do
        # wrong only one company
        expect(search(updated: :month, year: nil))
          .to eq ["Death Star+1990", "Death Star+1991", "Death Star+1992"]
      end
    end
  end

  describe "#published_query" do
    let(:default_filters) { { metric_id: answer.card.metric_id } }
    let(:answer) { answer_name.card }

    context "when user is not steward" do
      let(:answer_name) { "Jedi+deadliness+Death_Star+1977" }

      it "implicitly finds answers.unpublished = nil" do
        expect(search).to include(answer_name)
      end

      it "implicitly finds answer.unpublished = false" do
        answer.unpublished_card.update! content: 0
        expect(search).to include(answer_name)
      end

      it "implicitly does not find answer.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(search).not_to include(answer_name)
      end

      it "finds no answers when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(search(published: "false")).to be_empty
      end
    end

    context "when user is steward" do
      let(:answer_name) { "Joe User+RM+Apple Inc+2015" }

      it "implicitly does not find answers.unpublished = true" do
        answer.unpublished_card.update! content: 1
        expect(search).not_to include(answer_name)
      end

      it "finds stewarded unpublished answer when looking for unpublished" do
        answer.unpublished_card.update! content: 1
        expect(search(published: "false").first).to eq(answer_name)
      end

      it "finds stewarded unpublished answer when looking for all" do
        answer.unpublished_card.update! content: 1
        expect(search(published: :all)).to include(answer_name)
      end
    end
  end
end
