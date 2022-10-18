RSpec.describe Card::AnswerQuery do
  include_context "answer query"

  RESEARCHED_TITLES = ["Industry Class", "Sector Industry", "Weapons", "big multi",
                       "big single", "researched number 2", "researched number 3",
                       "small multi", "small single", "Address"].freeze

  let(:default_filters) { { company_id: company_name.card_id, year: :latest } }
  let(:answer_parts) { [1, -1] } # metric and year
  let(:company_name) { "Death_Star" }

  let(:all_metrics) { Card.search type: :metric, return: :name }
  let(:all_metric_titles) { all_metrics.map { |n| n.to_name[1].to_name } }

  let(:researched_metric_keys) do
    ::Set.new(latest_answers.map { |n| n.to_name.left_name.key })
  end

  let :unresearched_metric_keys do
    all_metric_titles.reject { |n| researched_metric_keys.include? n.key }.sort
  end

  let :latest_answers do # by metric title
    [
      "Company Category+2019", "cost of planets destroyed+1977", "darkness rating+1977",
      "deadliness+1977", "deadliness+1977", "deadliness+1977", "descendant 1+1977",
      "descendant 2+1977", "descendant hybrid+1977", "dinosaurlabor+2010",
      "disturbances in the Force+2001", "disturbances in the Force+2001",
      "double friendliness+1977", "friendliness+1977", "know the unknowns+1977",
      "more evil+1977", "researched number 1+1977", "RM+1977", "Sith Lord in Charge+1977",
      "Victims by Employees+1977"
    ]
  end

  let :researched do
    [
      "cost of planets destroyed+1977", "deadliness+1977", "dinosaurlabor+2010",
      "disturbances in the Force+2001", "researched number 1+1977", "RM+1977",
      "Sith Lord in Charge+1977", "Victims by Employees+1977"
    ]
  end

  def unanswers year=Time.now.year
    with_year unresearched_metric_keys, year
  end

  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  context "with single filter condition" do
    context "with keyword" do
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

    context "with year" do
      it "finds exact match" do
        expect(search(year: "2000"))
          .to eq with_year(["dinosaurlabor", "disturbances in the Force",
                            "disturbances in the Force"], 2000)
      end
    end

    context "with research policy" do
      it "finds exact match" do
        expect(search(research_policy: "Designer Assessed"))
          .to eq ["dinosaurlabor+2010"]
      end
    end

    context "with metric type" do
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
        expect(search(metric_type: "Researched")).to contain_exactly(*researched)
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

    context "with calculated" do
      it "finds calculated answers" do
        expect(search(calculated: :calculated))
          .to eq(["darkness rating+1977",
                  "deadliness+1977",
                  "deadliness+1977",
                  "descendant 1+1977",
                  "descendant 2+1977",
                  "disturbances in the Force+2001",
                  "double friendliness+1977",
                  "friendliness+1977",
                  "know the unknowns+1977"])
      end
    end

    context "with topic" do
      it "finds exact match" do
        expect(search(topic: "Force")).to eq ["disturbances in the Force+2001"]
      end
    end

    context "with bookmark" do
      it "finds bookmarked" do
        expect(search(bookmark: :bookmark))
          .to eq ["disturbances in the Force+2001"]
      end

      it "finds not bookmarked" do
        latest = latest_answers
        marked = "disturbances in the Force+2001"
        latest.slice! latest.index(marked)
        expect(search(bookmark: :nobookmark)).to eq(latest)
      end
    end

    context "with status" do
      let :answers do
        latest_answers + with_year(["researched number 2", "researched number 3",
                                    "small multi", "small single"])
      end
      let :unknown_answers do
        with_year(
          ["deadliness", "deadliness", "deadliness",
           "double friendliness", "friendliness", "Victims by Employees"], 1977
        )
      end

      context "when :none" do
        it "finds not researched" do
          expect(search(status: :none)).to contain_exactly(*unanswers)
        end
      end

      it "finds all values" do
        filtered = search(status: :all)
        expect(filtered).to include(*answers)
        expect(filtered.size)
          .to eq Card.search(type_id: Card::MetricID, return: :count)
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

    describe "filter by update date" do
      before { Timecop.freeze Wikirate::HAPPY_BIRTHDAY }
      after { Timecop.return }

      let(:answer_parts) { [1] }
      let(:default_filters) { { company_id: company_name.card_id } }

      it "finds today's edits" do
        expect(search(updated: :today)).to eq ["disturbances in the Force"]
      end

      it "finds this week's edits" do
        expect(search(updated: :week))
          .to eq ["disturbances in the Force", "disturbances in the Force"]
      end

      it "finds this months's edits" do
        # I added 'metric_type: "Researched"' because the new yaml loading
        # made it so that calculated metrics, including scores, were created before the
        # researched answers, which meant timecop affect the calculation times
        expect(search(updated: :month, metric_type: "Researched"))
          .to eq(["disturbances in the Force"] * 3)
      end
    end

    context "with invalid filter key" do
      it "doesn't matter" do
        expect(search(not_a_filter: "Death")).to contain_exactly(*latest_answers)
      end
    end

    context "with dataset" do
      it "finds exact match" do
        expect(search(dataset: "Evil Dataset"))
          .to eq ["disturbances in the Force+2001"]
      end
    end
  end

  context "with multiple filter conditions" do
    context "with filter for missing values and ..." do
      it "... year" do
        nr2001 = unanswers(2001) + with_year(
          ["Victims by Employees", "cost of planets destroyed",
           "darkness rating", "deadliness", "deadliness",
           "deadliness", "dinosaurlabor", "friendliness",
           "Sith Lord in Charge", "descendant 1", "descendant 2",
           "descendant hybrid", "Company Category",
           "RM", "researched number 1", "know the unknowns",
           "more evil", "double friendliness"],
          2001
        )
        nr2001.delete "disturbances in the Force+2001"
        filtered = search(status: :none, year: "2001")
        expect(filtered)
          .to contain_exactly(*nr2001)
      end

      it "... keyword" do
        expect(search(status: :none, metric_name: "number 2"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      it "... dataset" do
        expect(search(status: :none, dataset: "Evil Dataset"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      it "... metric_type" do
        expect(search(status: :none, metric_type: "Researched"))
          .to contain_exactly(*with_year(RESEARCHED_TITLES))
      end

      it "... policy and year" do
        expect(search(status: :none,
                      research_policy: "Designer Assessed",
                      year: "2001"))
          .to eq ["dinosaurlabor+2001", "Industry Class+2001", "researched number 3+2001"]
      end
    end

    context "with filter for all values and ..." do
      it "... dataset" do
        expect(search(status: :all, dataset: "Evil Dataset"))
          .to contain_exactly("disturbances in the Force+2001",
                              *with_year("researched number 2"))
      end

      it "... year" do
        expect(search(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_metric_titles, 2001))
      end

      it "... policy and year" do
        expect(search(status: :all,
                      research_policy: "Designer Assessed",
                      year: "2001"))
          .to eq ["dinosaurlabor+2001", "Industry Class+2001", "researched number 3+2001"]
      end

      it "... metric_type" do
        expect(search(status: :all, metric_type: "Researched"))
          .to contain_exactly(*(with_year(RESEARCHED_TITLES) + researched))
      end
    end

    it "policy and bookmark" do
      expect(search(policy: "Evil Dataset", bookmark: :bookmark))
        .to eq(["disturbances in the Force+2001"])
    end

    it "year and industry" do
      Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) do
        expect(search({ year: "1991", topic: "Force",
                        bookmark: :bookmark, updated: :week }))
          .to eq(with_year("disturbances in the Force", 1991))
      end
    end

    it "all in" do
      Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) do
        expect(search({ year: "1992", topic: "Force", bookmark: :bookmark,
                        updated: :month, dataset: "Evil Dataset",
                        research_policy: "Community Assessed", name: "in the",
                        metric_type: "Researched" }))
          .to eq(with_year("disturbances in the Force", 1992))
      end
    end
  end
end
