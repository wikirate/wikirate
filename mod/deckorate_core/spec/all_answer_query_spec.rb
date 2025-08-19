RSpec.describe Card::AllAnswerQuery do
  include_context "answer query"

  context "with fixed company" do
    let(:default_filters) { { company_id: company_name.card_id, year: :latest } }
    let(:answer_parts) { [1, -1] } # metric and year
    let(:company_name) { "Death_Star" }

    let(:all_metrics) { Card.search type: :metric, return: :name }
    let(:all_metric_titles) { all_metrics.map { |n| n.to_name[1].to_name } }

    let :researched_titles do
      ["Industry Class", "Sector Industry", "Weapons", "big multi", "big single",
       "researched number 2", "researched number 3", "small multi", "small single",
       "Address"]
    end

    let(:researched_metric_keys) do
      ::Set.new(latest_death_star_answers.map { |n| n.to_name.left_name.key })
    end

    let :unresearched_metric_keys do
      all_metric_titles.reject { |n| researched_metric_keys.include? n.key }.sort
    end

    def unanswers year=Time.now.year
      with_year unresearched_metric_keys, year
    end

    context "with status :all" do
      let :all_answers do
        latest_answers + with_year(["researched number 2", "researched number 3",
                                    "small multi", "small single"])
      end

      it "finds all values" do
        filtered = search(status: :all)
        expect(filtered).to include(*latest_death_star_answers)
        expect(filtered.size)
          .to eq Card.search(type: :metric, return: :count)
      end

      specify "and dataset" do
        expect(search(status: :all, dataset: "Evil Dataset"))
          .to contain_exactly("disturbances in the Force+2001",
                              *with_year("researched number 2"))
      end

      specify "and year" do
        expect(search(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_metric_titles, 2001))
      end

      specify "and policy and year" do
        expect(search(status: :all,
                      research_policy: "Steward Assessed",
                      year: "2001"))
          .to eq ["dinosaurlabor+2001", "Industry Class+2001", "researched number 3+2001"]
      end

      specify "metric_type" do
        expect(search(status: :all, metric_type: "Researched"))
          .to contain_exactly(
            *(with_year(researched_titles) + researched_death_star_answers)
          )
      end
    end

    context "with status :none" do
      it "finds not researched" do
        expect(search(status: :none)).to contain_exactly(*unanswers)
      end

      specify "and year" do
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

      specify "and keyword" do
        expect(search(status: :none, metric_keyword: "number 2"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      specify "and dataset" do
        expect(search(status: :none, dataset: "Evil Dataset"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      specify "and metric_type" do
        expect(search(status: :none, metric_type: "Researched"))
          .to contain_exactly(*with_year(researched_titles))
      end

      specify "and policy and year" do
        expect(search(status: :none,
                      research_policy: "Steward Assessed",
                      year: "2001"))
          .to eq ["dinosaurlabor+2001", "Industry Class+2001", "researched number 3+2001"]
      end
    end
  end

  context "with fixed metric" do
    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    context "with status :all" do
      it "finds existing and non-existing values" do
        expect(search(status: :all))
          .to include(*(latest_disturbance_answers + missing_disturbance_answers))
      end

      specify "and dataset" do
        expect(search(status: :all, dataset: "Evil Dataset"))
          .to contain_exactly("Death Star+2001", "SPECTRE+2000",
                              *with_year("Los Pollos Hermanos"))
      end

      specify "and year" do
        i = all_companies.index("Death Star")
        all_companies[i] = "Death Star"
        expect(search(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_companies, 2001))
      end

      specify "and company_category and year" do
        expect(search(status: :all, company_category: "A", year: "2001"))
          .to contain_exactly(*with_year(["SPECTRE", "Death Star"], 2001))
      end
    end

    context "with status :none" do
      it "finds missing values" do
        expect(search(status: :none))
          .to contain_exactly(*missing_disturbance_answers)
      end

      specify "and year" do
        missing2000 = missing_disturbance_answers 2000
        missing2000 << "Slate Rock and Gravel Company+2000"
        expect(search(status: :none, year: "2000").sort)
          .to eq(missing2000.sort)
      end

      specify "and keyword" do
        expect(search(status: :none, company_keyword: "Inc").sort)
          .to eq(with_year(["Apple Inc.", "Google Inc."]))
      end

      specify "and dataset" do
        expect(search(status: :none, dataset: "Evil Dataset").sort)
          .to eq(with_year(["Los Pollos Hermanos"]))
      end

      specify "and company_category" do
        expect(search(status: :none, company_category: "A"))
          .to eq []
      end

      specify "and company_category and year" do
        expect(search(status: :none, company_category: "A", year: "2001"))
          .to eq ["SPECTRE+2001"]
      end
    end
  end
end
