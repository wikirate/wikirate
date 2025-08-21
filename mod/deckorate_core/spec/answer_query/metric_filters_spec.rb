RSpec.describe Card::AnswerQuery::MetricFilters do
  include_context "answer query"

  context "with fixed company" do
    let(:default_filters) { { company_id: company_name.card_id, year: :latest } }
    let(:answer_parts) { [1, -1] } # metric and year
    let(:company_name) { "Death_Star" }

    describe "#filter_by_metric_keyword" do
      it "finds exact match" do
        expect(search(metric_keyword: "Force"))
          .to eq with_year(["disturbances in the Force",
                            "disturbances in the Force"], 2001)
      end

      it "finds partial match" do
        expect(search(metric_keyword: "dead"))
          .to eq with_year(%w[deadliness deadliness deadliness], 1977)
      end

      it "ignores case" do
        expect(search(metric_keyword: "DeAd"))
          .to eq with_year(%w[deadliness deadliness deadliness], 1977)
      end
    end

    context "with MetricQuery field" do
      specify "assessment" do
        expect(search(assessment: "Steward Assessed")).to eq ["dinosaurlabor+2010"]
      end

      context "when metric type" do
        it "finds formulas" do
          expect(search(metric_type: "Formula"))
            .to eq ["Company Category+2019",
                    "disturbance delta+2001",
                    "double friendliness+1977",
                    "friendliness+1977",
                    "know the unknowns+1977"]
        end

        it "finds scores" do
          expect(search(metric_type: "Score"))
            .to eq ["deadliness+1977",
                    "deadliness+1977",
                    "disturbances in the Force+2001"]
        end

        it "finds wikiratings" do
          expect(search(metric_type: "Rating")).to eq ["darkness rating+1977"]
        end

        it "finds researched" do
          expect(search(metric_type: "Researched"))
            .to contain_exactly(*researched_death_star_answers)
        end

        it "finds combinations" do
          expect(search(metric_type: %w[Score Formula]))
            .to eq ["Company Category+2019", "deadliness+1977", "deadliness+1977",
                    "disturbance delta+2001",
                    "disturbances in the Force+2001", "double friendliness+1977",
                    "friendliness+1977", "know the unknowns+1977"]
        end
      end

      context "with value type" do
        it "finds category metrics" do
          expect(search(value_type: "Category"))
            .to eq(["dinosaurlabor+2010",
                    "disturbances in the Force+2001",
                    "more evil+1977"])
        end
      end
    end

    specify "#filter_by_topic" do
      expect(search(topic: %i[esg_topics environment].cardname)).to eq ["disturbances in the Force+2001"]
    end

    describe "#filter_by_bookmarkht6" do
      it "finds bookmarked" do
        expect(search(bookmark: :bookmark))
          .to eq ["disturbances in the Force+2001"]
      end

      it "finds not bookmarked" do
        latest = latest_death_star_answers
        marked = "disturbances in the Force+2001"
        latest.slice! latest.index(marked)
        expect(search(bookmark: :nobookmark)).to eq(latest)
      end
    end

    context "with invalid filter key" do
      it "doesn't matter" do
        expect(search(not_a_filter: "Death"))
          .to contain_exactly(*latest_death_star_answers)
      end
    end

    describe "#dataset_query" do
      it "finds exact match" do
        expect(search(dataset: "Evil Dataset")).to eq ["disturbances in the Force+2001"]
      end
    end
  end

  context "with fixed metric" do
    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    specify "#dataset_query" do
      expect(search(dataset: "Evil Dataset").sort)
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end
  end
end
