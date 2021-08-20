# require "./test/seed"

RSpec.describe Card::AnswerQuery do
  LATEST_ANSWERS = ["Death Star+2001",
                    "Monster Inc+2000",
                    "Slate Rock and Gravel Company+2005",
                    "SPECTRE+2000"].freeze

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
  def short_answers list
    list.map { |a| "#{a.company_name}+#{a.year}" }
  end

  # @return [Array] of company+year strings
  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  # @return [Array] of company+year strings
  def filter_by filter, latest=true
    filter.reverse_merge! year: :latest if latest
    run_query filter
  end

  # @return [Array] of company+year strings
  def sort_by sort_by, sort_dir="asc"
    run_query({ year: :latest }, sort_by => sort_dir)
  end

  def run_query filter, sort={}
    short_answers described_class.new(filter.merge(metric_id: metric.id), sort).run
  end

  context "with single filter condition" do
    context "with keyword" do
      it "finds exact match" do
        expect(filter_by(company_name: "Death")).to eq ["Death Star+2001"]
      end

      it "finds partial match" do
        expect(filter_by(company_name: "at"))
          .to eq ["Death Star+2001", "Slate Rock and Gravel Company+2005"]
      end

      it "ignores case" do
        expect(filter_by(company_name: "death"))
          .to eq ["Death Star+2001"]
      end
    end

    it "finds exact match by year" do
      expect(filter_by(year: "2000"))
        .to eq with_year(["Death Star", "Monster Inc",  "SPECTRE"], 2000)
    end

    it "finds exact match by project" do
      expect(filter_by(project: "Evil Project"))
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end

    it "finds exact match by company_category" do
      expect(filter_by(company_category: "A"))
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end

    context "with relationship metric" do
      it "finds companies by related company group" do
        @metric_name = "Commons+Supplied by"
        expect(filter_by(related_company_group: "Googliest"))
          .to eq(["SPECTRE+2000"])
      end
    end

    context "with inverse relationship metric" do
      it "finds companies by related company group" do
        @metric_name = "Commons+Supplier of"
        expect(filter_by(related_company_group: "Deadliest"))
          .to eq(["Los Pollos Hermanos+2000", "Google LLC+2000"])
      end
    end

    context "with value filter" do
      let(:answers) do
        LATEST_ANSWERS + missing_answers
      end

      it "finds missing values" do
        expect(filter_by(status: :none))
          .to contain_exactly(*missing_answers)
      end

      it "finds all values" do
        filtered = filter_by(status: :all)
        expect(filtered).to include(*answers)
      end

      context "with update date filter" do
        before do
          Timecop.freeze(SharedData::HAPPY_BIRTHDAY)
        end
        after do
          Timecop.return
        end
        it "finds today's edits" do
          expect(filter_by({ updated: :today }, false))
            .to eq(["Death Star+1990"])
        end

        it "finds this week's edits" do
          expect(filter_by({ updated: :week }, false))
            .to eq ["Death Star+1990", "Death Star+1991"]
        end

        it "finds this months's edits" do
          # wrong only one company
          expect(filter_by({ updated: :month }, false))
            .to eq ["Death Star+1990", "Death Star+1991", "Death Star+1992"]
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
        expect(filter_by(status: :none, year: "2000").sort)
          .to eq(missing2000.sort)
      end

      it "... keyword" do
        expect(filter_by(status: :none, company_name: "Inc").sort)
          .to eq(with_year(["AT&T Inc.", "Amazon.com, Inc.",
                            "Apple Inc.", "Google Inc."]))
      end

      it "... project" do
        expect(filter_by(status: :none, project: "Evil Project").sort)
          .to eq(with_year(["Los Pollos Hermanos"]))
      end

      it "... company_category" do
        expect(filter_by(status: :none,
                         company_category: "A"))
          .to eq []
      end

      it "... company_category and year" do
        expect(filter_by(status: :none,
                         company_category: "A",
                         year: "2001"))
          .to eq ["SPECTRE+2001"]
      end
    end

    context "when filtering for all values and ..." do
      it "... project" do
        expect(filter_by(status: :all, project: "Evil Project"))
          .to contain_exactly("Death Star+2001", "SPECTRE+2000",
                              *with_year("Los Pollos Hermanos"))
      end

      it "... year" do
        i = all_companies.index("Death Star")
        all_companies[i] = "Death Star"
        expect(filter_by(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_companies, 2001))
      end

      it "... company_category and year" do
        expect(filter_by(status: :all,
                         company_category: "A",
                         year: "2001"))
          .to contain_exactly(*with_year(["SPECTRE", "Death Star"], 2001))
      end
    end

    it "project and company_category" do
      expect(filter_by(project: "Evil Project",
                       company_category: "A"))
        .to eq(["Death Star+2001", "SPECTRE+2000"])
    end
    it "year and company_category" do
      expect(filter_by(year: "1977",
                       company_category: "A"))
        .to eq(with_year("Death Star", 1977))
    end
    it "all in" do
      Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
        expect(filter_by(year: "1990",
                         company_category: "A",
                         project: "Evil Project",
                         updated: :today,
                         name: "star"))
          .to eq(with_year("Death Star", 1990))
      end
    end
  end

  context "with sort conditions" do
    it "sorts by company name (asc)" do
      expect(sort_by(:company_name)).to eq(LATEST_ANSWERS)
    end

    it "sorts by company name (desc)" do
      expect(sort_by(:company_name, "desc"))
        .to eq(LATEST_ANSWERS.reverse)
    end

    it "sorts categories by value" do
      res = sort_by(:value)
      yes_index = res.index "Death Star+2001"
      no_index = res.index "Slate Rock and Gravel Company+2005"
      expect(no_index).to be < yes_index
    end

    it "sorts numerics by value" do
      @metric_name = "Jedi+deadliness"
      expect(sort_by(:value))
        .to eq(["Samsung+1977",
                "Slate Rock and Gravel Company+2005",
                "Los Pollos Hermanos+1977",
                "SPECTRE+1977",
                "Death Star+1977"])
    end

    it "sorts floats by value" do
      @metric_name = "Jedi+Victims by Employees"
      expect(sort_by(:value))
        .to eq(with_year(["Samsung",
                          "Slate Rock and Gravel Company",
                          "Monster Inc",
                          "Los Pollos Hermanos",
                          "Death Star",
                          "SPECTRE"], 1977))
    end
  end

  context "with multi-category metric" do
    let(:metric) { Card["Joe_User+big_multi"] }

    it "handles value arrays" do
      expect(run_query(value: ["1"])).to eq(["Sony Corporation+2010"])
    end
  end
end
