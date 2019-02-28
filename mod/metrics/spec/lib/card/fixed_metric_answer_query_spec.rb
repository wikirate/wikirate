require "./test/seed"

RSpec.describe Card::FixedMetricAnswerQuery do
  LATEST_ANSWERS = %w[Death_Star+2001
                      Monster_Inc+2000
                      Slate_Rock_and_Gravel_Company+2005
                      SPECTRE+2000].freeze

  let(:metric) { Card[@metric_name || "Jedi+disturbances in the Force"] }
  let(:all_companies) { Card.search type_id: Card::WikirateCompanyID, return: :name }

  let :missing_companies do
    latest_answer_keys = ::Set.new(LATEST_ANSWERS.map { |n| n.to_name.left_name.key })
    all_companies.reject { |name| latest_answer_keys.include? name.to_name.key }
  end

  # @return [Array] of company+year strings
  def missing_answers year=Time.now.year
    with_year missing_companies, year
  end

  # @return [Array] of company+year strings
  def answers list
    list.map { |a| "#{a.company_name}+#{a.year}" }
  end

  # @return [Array] of company+year strings
  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  # @return [Array] of company+year strings
  def filter_by filter, latest=true
    filter.reverse_merge! year: :latest if latest
    answers described_class.new(metric.id, filter).run
  end

  # @return [Array] of company+year strings
  def sort_by key, order="asc"
    filter = { year: :latest }
    sort = { sort_by: key, sort_order: order }
    answers described_class.new(metric.id, filter, sort).run
  end

  context "with single filter condition" do
    context "with keyword" do
      it "finds exact match" do
        expect(filter_by(name: "Death")).to eq ["Death_Star+2001"]
      end

      it "finds partial match" do
        expect(filter_by(name: "at"))
          .to eq %w[Death_Star+2001 Slate_Rock_and_Gravel_Company+2005]
      end

      it "ignores case" do
        expect(filter_by(name: "death"))
          .to eq ["Death_Star+2001"]
      end
    end

    it "finds exact match by year" do
      expect(filter_by(year: "2000"))
        .to eq with_year(%w[Death_Star Monster_Inc SPECTRE], 2000)
    end

    it "finds exact match by project" do
      expect(filter_by(project: "Evil Project"))
        .to eq %w[Death_Star+2001 SPECTRE+2000]
    end

    it "finds exact match by industry" do
      expect(filter_by(industry: "Technology Hardware"))
        .to eq %w[Death_Star+2001 SPECTRE+2000]
    end

    context "with value filter" do
      let(:all_answers) do
        LATEST_ANSWERS + missing_answers
      end

      it "finds missing values" do
        expect(filter_by(metric_value: :none))
          .to contain_exactly(*missing_answers)
      end

      it "finds all values" do
        filtered = filter_by(metric_value: :all)
        expect(filtered)
          .to include(*all_answers)
      end

      context "with update date filter" do
        before do
          Timecop.freeze(SharedData::HAPPY_BIRTHDAY)
        end
        after do
          Timecop.return
        end
        it "finds today's edits" do
          expect(filter_by({ metric_value: :today }, false))
            .to eq %w[Death_Star+1990]
        end

        it "finds this week's edits" do
          expect(filter_by({ metric_value: :week }, false))
            .to eq %w[Death_Star+1990 Death_Star+1991]
        end

        it "finds this months's edits" do
          # wrong only one company
          expect(filter_by({ metric_value: :month }, false))
            .to eq %w[Death_Star+1990 Death_Star+1991 Death_Star+1992]
        end
      end
    end
    context "when filter key is invalid" do
      it "doesn't matter" do
        expect(filter_by(not_a_filter: "Death"))
          .to eq LATEST_ANSWERS
      end
    end
  end

  context "with multiple filter conditions" do
    context "with filter for missing values and ..." do
      it "... year" do
        missing2000 = missing_answers(2000)
        missing2000 << "Slate Rock and Gravel Company+2000"
        expect(filter_by(metric_value: :none, year: "2000").sort)
          .to eq(missing2000.sort)
      end

      it "... keyword" do
        expect(filter_by(metric_value: :none, name: "Inc").sort)
          .to eq(with_year(["AT&T Inc.", "Amazon.com, Inc.",
                            "Apple Inc.", "Google Inc."]))
      end

      it "... project" do
        expect(filter_by(metric_value: :none, project: "Evil Project").sort)
          .to eq(with_year(["Los Pollos Hermanos"]))
      end

      it "... industry" do
        expect(filter_by(metric_value: :none,
                         industry: "Technology Hardware"))
          .to eq []
      end

      it "... industry and year" do
        expect(filter_by(metric_value: :none,
                         industry: "Technology Hardware",
                         year: "2001"))
          .to eq ["SPECTRE+2001"]
      end
    end

    context "when filtering for all values and ..." do
      it "... project" do
        expect(filter_by(metric_value: :all, project: "Evil Project"))
          .to contain_exactly("Death_Star+2001", "SPECTRE+2000",
                              *with_year("Los Pollos Hermanos"))
      end

      it "... year" do
        i = all_companies.index("Death Star")
        all_companies[i] = "Death_Star"
        expect(filter_by(metric_value: :all, year: "2001"))
          .to contain_exactly(*with_year(all_companies, 2001))
      end

      it "... industry and year" do
        expect(filter_by(metric_value: :all,
                         industry: "Technology Hardware",
                         year: "2001"))
          .to contain_exactly(*with_year(%w[SPECTRE Death_Star], 2001))
      end
    end

    it "project and industry" do
      expect(filter_by(project: "Evil Project",
                       industry: "Technology Hardware"))
        .to eq(["Death_Star+2001", "SPECTRE+2000"])
    end
    it "year and industry" do
      expect(filter_by(year: "1977",
                       industry: "Technology Hardware"))
        .to eq(with_year("Death_Star", 1977))
    end
    it "all in" do
      Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
        expect(filter_by(year: "1990",
                         industry: "Technology Hardware",
                         project: "Evil Project",
                         metric_value: :today,
                         name: "star"))
          .to eq(with_year("Death_Star", 1990))
      end
    end
  end

  context "with sort conditions" do
    it "sorts by company name (asc)" do
      expect(sort_by(:company_name)).to eq(%w[Death_Star+2001
                                              Monster_Inc+2000
                                              Slate_Rock_and_Gravel_Company+2005
                                              SPECTRE+2000])
    end

    it "sorts by company name (desc)" do
      expect(sort_by(:company_name, "desc"))
        .to eq(%w[Death_Star+2001
                  Monster_Inc+2000
                  Slate_Rock_and_Gravel_Company+2005
                  SPECTRE+2000].reverse)
    end

    it "sorts categories by value" do
      res = sort_by(:value)
      yes_index = res.index "Death_Star+2001"
      no_index = res.index "Slate_Rock_and_Gravel_Company+2005"
      expect(no_index).to be < yes_index
    end

    it "sorts numerics by value" do
      @metric_name = "Jedi+deadliness"
      expect(sort_by(:value))
        .to eq(%w[Samsung+1977
                  Slate_Rock_and_Gravel_Company+2005
                  Los_Pollos_Hermanos+1977
                  SPECTRE+1977
                  Death_Star+1977])
    end

    it "sorts floats by value" do
      @metric_name = "Jedi+Victims by Employees"
      expect(sort_by(:value))
        .to eq(with_year(%w[Samsung
                            Slate_Rock_and_Gravel_Company
                            Monster_Inc
                            Los_Pollos_Hermanos
                            Death_Star
                            SPECTRE], 1977))
    end
  end
end
