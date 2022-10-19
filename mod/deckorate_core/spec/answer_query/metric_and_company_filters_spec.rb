RSpec.describe Card::AnswerQuery do
  include_context "answer query"

  let(:default_filters) { { company_id: company_name.card_id, year: :latest } }
  let(:answer_parts) { [1, -1] } # metric and year
  let(:company_name) { "Death_Star" }

  describe "#metric_name_query" do
    it "finds exact match" do
      expect(search(metric_name: "disturbances in the Force"))
        .to eq with_year(["disturbances in the Force",
                          "disturbances in the Force"], 2001)
    end

    it "finds partial match" do
      expect(search(metric_name: "dead"))
        .to eq with_year(%w[deadliness deadliness deadliness], 1977)
    end

    it "ignores case" do
      expect(search(metric_name: "DeAd"))
        .to eq with_year(%w[deadliness deadliness deadliness], 1977)
    end
  end

  context "with MetricQuery field" do
    specify "research policy" do
      expect(search(research_policy: "Designer Assessed")).to eq ["dinosaurlabor+2010"]
    end

    context "when metric type" do
      it "finds formulas" do
        expect(search(metric_type: "Formula"))
          .to eq ["Company Category+2019", "double friendliness+1977",
                  "friendliness+1977", "know the unknowns+1977"]
      end

      it "finds scores" do
        expect(search(metric_type: "Score"))
          .to eq ["deadliness+1977", "deadliness+1977", "disturbances in the Force+2001"]
      end

      it "finds wikiratings" do
        expect(search(metric_type: "WikiRating")).to eq ["darkness rating+1977"]
      end

      it "finds researched" do
        expect(search(metric_type: "Researched"))
          .to contain_exactly(*researched_death_star_answers)
      end

      it "finds combinations" do
        expect(search(metric_type: %w[Score Formula]))
          .to eq ["Company Category+2019", "deadliness+1977", "deadliness+1977",
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

    specify "topic" do
      expect(search(topic: "Force")).to eq ["disturbances in the Force+2001"]
    end
  end

  describe "#bookmark_query" do
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

  context "with status" do
    let :unknown_answers do
      with_year(
        ["deadliness", "deadliness", "deadliness",
         "double friendliness", "friendliness", "Victims by Employees"], 1977
      )
    end

    context "when companies have unknown values" do
      let(:company_name) { "Samsung" }

      it "finds unknown values" do
        expect(search(status: :unknown))
          .to eq unknown_answers
      end

      it "finds known values" do
        all_known = search(status: :known).all? do |a|
          a.s.include?("researched number") || a.s.include?("descendant")
        end
        expect(all_known).to be_truthy
      end
    end
  end

  context "with invalid filter key" do
    it "doesn't matter" do
      expect(search(not_a_filter: "Death"))
        .to contain_exactly(*latest_death_star_answers)
    end
  end

  context "with dataset" do
    it "finds exact match" do
      expect(search(dataset: "Evil Dataset"))
        .to eq ["disturbances in the Force+2001"]
    end
  end

  context "with multiple filter conditions" do
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
