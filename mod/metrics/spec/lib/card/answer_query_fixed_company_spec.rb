require "./test/seed"

RSpec.describe Card::AnswerQuery do
  RESEARCHED_TITLES = ["Industry Class", "Weapons", "big multi", "big single",
                       "researched number 2", "researched number 3", "small multi",
                       "small single"].freeze

  let(:company) { Card[@company_name || "Death_Star"] }
  let(:all_metrics) { Card.search type_id: Card::MetricID, return: :name }
  let(:all_metric_titles) { titles_of all_metrics }

  let(:researched_metric_keys) do
    ::Set.new(latest_answers.map { |n| n.to_name.left_name.key })
  end

  let :unresearched_metric_keys do
    all_metric_titles.reject { |n| researched_metric_keys.include? n.key }
  end

  let :latest_answers_by_bookmarks do
    ["disturbances in the Force+2001", "Victims by Employees+1977",
     "Sith Lord in Charge+1977", "dinosaurlabor+2010", "cost of planets destroyed+1977",
     "friendliness+1977", "deadliness+Joe User+1977", "deadliness+Joe Camel+1977",
     "disturbances in the Force+Joe User+2001", "darkness rating+1977",
     "descendant 1+1977", "descendant 2+1977", "descendant hybrid+1977",
     "double friendliness+1977",
     "researched number 1+1977", "know the unknowns+1977", "more evil+1977", "RM+1977",
     "deadliness+1977"]
  end

  let :latest_answers do # by metric name
    ["dinosaurlabor+2010", "cost of planets destroyed+1977", "darkness rating+1977",
     "deadliness+1977", "deadliness+Joe Camel+1977", "deadliness+Joe User+1977",
     "disturbances in the Force+2001", "disturbances in the Force+Joe User+2001",
     "double friendliness+1977", "friendliness+1977", "know the unknowns+1977",
     "more evil+1977",
     "Sith Lord in Charge+1977", "Victims by Employees+1977", "descendant 1+1977",
     "descendant 2+1977", "descendant hybrid+1977", "researched number 1+1977", "RM+1977"]
  end

  let :researched do
    ["dinosaurlabor+2010", "cost of planets destroyed+1977", "deadliness+1977",
     "disturbances in the Force+2001", "Sith Lord in Charge+1977",
     "Victims by Employees+1977", "RM+1977", "researched number 1+1977"]
  end

  def unall_answers year=Time.now.year
    with_year unresearched_metric_keys, year
  end

  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  # @return [Array] of metric_title(+scorer)+year strings
  def answers list
    list.map do |a|
      [a.name.parts[1..-3], a.name.parts.last].flatten.join "+"
    end
  end

  def titles_of metric_names
    metric_names.map { |n| n.to_name[1..-1].to_name }
  end

  # @return [Array] of metric_title(+scorer)+year strings
  def filter_by filter, latest=true
    filter.reverse_merge! year: :latest if latest
    answers run_query filter, sort_by: :metric_name
  end

  # @return [Array] of answer cards
  def sort_by key, order=:asc
    run_query({ year: :latest }, sort_by: key, sort_order: order)
  end

  def run_query filter, sort
    described_class.new(filter.merge(company_id: company.id), sort).run
  end

  context "with single filter condition" do
    context "with keyword" do
      it "finds exact match" do
        expect(filter_by(metric_name: "Jedi+disturbances in the Force+Joe User"))
          .to eq ["disturbances in the Force+Joe User+2001"]
      end

      it "finds partial match" do
        expect(filter_by(metric_name: "dead"))
          .to eq with_year(["deadliness", "deadliness+Joe Camel",
                            "deadliness+Joe User"], 1977)
      end

      it "ignores case" do
        expect(filter_by(metric_name: "DeAd"))
          .to eq with_year(["deadliness", "deadliness+Joe Camel",
                            "deadliness+Joe User"], 1977)
      end
    end

    context "with year" do
      it "finds exact match" do
        expect(filter_by(year: "2000"))
          .to eq with_year(["dinosaurlabor", "disturbances in the Force",
                            "disturbances in the Force+Joe User"], 2000)
      end
    end

    context "with research policy" do
      it "finds exact match" do
        expect(filter_by(research_policy: "Designer Assessed"))
          .to eq ["dinosaurlabor+2010"]
      end
    end

    context "with metric type" do
      it "finds formulas" do
        expect(filter_by(metric_type: "Formula"))
          .to eq ["double friendliness+1977", "friendliness+1977",
                  "know the unknowns+1977"]
      end

      it "finds scores" do
        expect(filter_by(metric_type: "Score"))
          .to eq ["deadliness+Joe Camel+1977", "deadliness+Joe User+1977",
                  "disturbances in the Force+Joe User+2001"]
      end

      it "finds wikiratings" do
        expect(filter_by(metric_type: "WikiRating")).to eq ["darkness rating+1977"]
      end

      it "finds researched" do
        expect(filter_by(metric_type: "Researched")).to contain_exactly(*researched)
      end

      it "finds combinations" do
        expect(filter_by(metric_type: %w[Score Formula]))
          .to eq ["deadliness+Joe Camel+1977", "deadliness+Joe User+1977",
                  "disturbances in the Force+Joe User+2001", "double friendliness+1977",
                  "friendliness+1977", "know the unknowns+1977"]
      end
    end

    context "with topic" do
      it "finds exact match" do
        expect(filter_by(topic: "Force")).to eq ["disturbances in the Force+2001"]
      end
    end

    context "with bookmark" do
      it "finds bookmarked" do
        expect(filter_by(bookmark: :bookmarked)).to eq ["disturbances in the Force+2001"]
      end

      it "finds not bookmarked" do
        expect(filter_by(bookmark: :nobookmark))
          .to eq latest_answers - ["disturbances in the Force+2001"]
      end
    end

    context "with status" do
      let :all_answers do
        latest_answers + with_year(["researched number 2", "researched number 3",
                                    "small multi", "small single"])
      end
      let :unknown_answers do
        with_year(
          ["deadliness", "deadliness+Joe Camel", "deadliness+Joe User",
           "double friendliness", "friendliness", "Victims by Employees"], 1977
        )
      end

      context "when :none" do
        it "finds not researched" do
          expect(filter_by(status: :none)).to contain_exactly(*unall_answers)
        end
      end

      it "finds all values" do
        filtered = filter_by(status: :all)
        expect(filtered).to include(*all_answers)
        expect(filtered.size)
          .to eq Card.search(type_id: Card::MetricID, return: :count)
      end

      it "finds unknown values" do
        @company_name = "Samsung"
        expect(filter_by(status: :unknown))
          .to eq unknown_answers
      end

      it "finds known values" do
        @company_name = "Samsung"
        all_known = filter_by(status: :known).all? do |a|
          a.include?("researched number") || a.include?("descendant")
        end
        expect(all_known).to be_truthy
      end
    end

    describe "filter by update date" do
      before { Timecop.freeze SharedData::HAPPY_BIRTHDAY }
      after { Timecop.return }

      it "finds today's edits" do
        expect(filter_by({ updated: :today }, false))
          .to eq ["disturbances in the Force+1990"]
      end

      it "finds this week's edits" do
        expect(filter_by({ updated: :week }, false))
          .to eq ["disturbances in the Force+1990", "disturbances in the Force+1991"]
      end

      it "finds this months's edits" do
        expect(filter_by({ updated: :month }, false))
          .to eq ["dinosaurlabor+2010", "disturbances in the Force+1990",
                  "disturbances in the Force+1991", "disturbances in the Force+1992"]
      end
    end

    context "with invalid filter key" do
      it "doesn't matter" do
        expect(filter_by(not_a_filter: "Death")).to contain_exactly(*latest_answers)
      end
    end

    context "with project" do
      it "finds exact match" do
        expect(filter_by(project: "Evil Project"))
          .to eq ["disturbances in the Force+2001"]
      end
    end
  end

  context "with multiple filter conditions" do
    context "with filter for missing values and ..." do
      it "... year" do
        nr2001 = unall_answers(2001) + with_year(
          ["Victims by Employees", "cost of planets destroyed",
           "darkness rating", "deadliness", "deadliness+Joe Camel",
           "deadliness+Joe User", "dinosaurlabor", "friendliness",
           "Sith Lord in Charge", "descendant 1", "descendant 2",
           "descendant hybrid",
           "RM", "researched number 1", "know the unknowns",
           "more evil", "double friendliness"],
          2001
        )
        nr2001.delete "disturbances in the Force+2001"
        filtered = filter_by(status: :none, year: "2001")
        expect(filtered)
          .to contain_exactly(*nr2001)
      end

      it "... keyword" do
        expect(filter_by(status: :none, metric_name: "number 2"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      it "... project" do
        expect(filter_by(status: :none, project: "Evil Project"))
          .to contain_exactly(*with_year(["researched number 2"]))
      end

      it "... metric_type" do
        expect(filter_by(status: :none, metric_type: "Researched"))
          .to contain_exactly(*with_year(RESEARCHED_TITLES))
      end

      it "... policy and year" do
        expect(filter_by(status: :none, research_policy: "Designer Assessed",
                         year: "2001"))
          .to eq ["dinosaurlabor+2001", "researched number 3+2001", "Industry Class+2001"]
      end
    end

    context "with filter for all values and ..." do
      it "... project" do
        expect(filter_by(status: :all, project: "Evil Project"))
          .to contain_exactly("disturbances in the Force+2001",
                              *with_year("researched number 2"))
      end

      it "... year" do
        expect(filter_by(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_metric_titles, 2001))
      end

      it "... policy and year" do
        expect(filter_by(status: :all,
                         research_policy: "Designer Assessed",
                         year: "2001"))
          .to eq ["dinosaurlabor+2001", "researched number 3+2001", "Industry Class+2001"]
      end

      it "... metric_type" do
        expect(filter_by(status: :all, metric_type: "Researched"))
          .to contain_exactly(*(with_year(RESEARCHED_TITLES) + researched))
      end
    end

    it "policy and bookmark" do
      expect(filter_by(policy: "Evil Project", bookmark: :bookmarked))
        .to eq(["disturbances in the Force+2001"])
    end

    it "year and industry" do
      Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
        expect(filter_by(year: "1991", topic: "Force",
                         bookmark: :bookmarked, updated: :week))
          .to eq(with_year("disturbances in the Force", 1991))
      end
    end

    it "all in" do
      Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
        expect(filter_by(year: "1992", topic: "Force", bookmark: :bookmarked,
                         updated: :month, project: "Evil Project",
                         research_policy: "Community Assessed", name: "in the",
                         metric_type: "Researched"))
          .to eq(with_year("disturbances in the Force", 1992))
      end
    end
  end

  context "with sort conditions" do
    let(:sorted_designer) { ["Fred", "Jedi", "Joe User"] }

    it "sorts by designer name (asc)" do
      sorted = sort_by(:metric_name, :asc).map { |a| a.name.parts.first }.uniq
      expect(sorted).to eq(sorted_designer)
    end

    it "sorts by designer name (desc)" do
      sorted = sort_by(:metric_name, :desc).map { |a| a.name.parts.first }.uniq
      expect(sorted).to eq(sorted_designer.reverse)
    end

    it "sorts by title" do
      sorted = sort_by(:title_name).map { |a| a.name.parts.second }
      indices =
        ["cost of planets destroyed", "darkness rating", "deadliness",
         "researched number 1", "Victims by Employees"].map do |t|
          sorted.index(t)
        end
      expect(indices).to eq [0, 1, 2, 15, 18]
    end

    it "sorts by recently updated" do
      expect(sort_by(:updated_at, :desc).first.name)
        .to eq "Fred+dinosaurlabor+Death_Star+2010"
    end

    it "sorts by bookmarked" do
      actual = answers sort_by(:bookmarkers, :desc)
      expected = latest_answers_by_bookmarks

      bookmarked = (0..1)
      not_bookmarked = (2..-1)

      expect(actual[bookmarked]).to contain_exactly(*expected[bookmarked])
      expect(actual[not_bookmarked]).to contain_exactly(*expected[not_bookmarked])
    end
  end
end
