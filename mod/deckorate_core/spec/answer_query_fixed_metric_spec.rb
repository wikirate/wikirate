# require "./test/seed"

RSpec.describe Card::AnswerQuery do
  include_context "answer query"

  LATEST_ANSWERS = ["Death Star+2001",
                    "Monster Inc+2000",
                    "Slate Rock and Gravel Company+2006",
                    "SPECTRE+2000"].freeze

  let(:metric_name) { "Jedi+disturbances in the Force" }
  let(:metric_id) { metric_name.card_id }
  let(:all_companies) { Card.search type: :wikirate_company, return: :name }
  let(:answer_parts) { [-2, -1] }
  let(:default_sort) { {} }

  let(:default_filters) { { metric_id: metric_id, year: :latest } }

  let :missing_companies do
    latest_answer_keys = ::Set.new(LATEST_ANSWERS.map { |n| n.to_name.left_name.key })
    all_companies.reject { |name| latest_answer_keys.include? name.to_name.key }
  end

  # @return [Array] of company+year strings
  def missing_answers year=Time.now.year
    with_year missing_companies, year
  end

  context "with single filter condition" do
    it "finds exact match by year" do
      expect(search(year: "2000"))
        .to eq with_year(["Death Star", "Monster Inc",  "SPECTRE"], 2000)
    end

    it "finds exact match by dataset" do
      expect(search(dataset: "Evil Dataset").sort)
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end

    it "finds exact match by company_category" do
      expect(search(company_category: "A").sort)
        .to eq ["Death Star+2001", "SPECTRE+2000"]
    end

    context "with relationship metric" do
      let(:metric_name) { "Commons+Supplied by" }

      it "finds companies by related company group" do
        expect(search(related_company_group: "Googliest"))
          .to eq(["SPECTRE+2000"])
      end
    end

    context "with inverse relationship metric" do
      let(:metric_name) { "Commons+Supplier of" }

      it "finds companies by related company group" do
        expect(search(related_company_group: "Deadliest"))
          .to eq(["Los Pollos Hermanos+2000", "Google LLC+2000"])
      end
    end

    context "with value filter" do
      let(:answers) do
        LATEST_ANSWERS + missing_answers
      end

      it "finds missing values" do
        expect(search(status: :none))
          .to contain_exactly(*missing_answers)
      end

      it "finds all values" do
        filtered = search(status: :all)
        expect(filtered).to include(*answers)
      end

      context "with update date filter" do
        before { Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) }
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
    context "when filter key is invalid" do
      it "doesn't matter" do
        expect(search(not_a_filter: "Death"))
          .to eq LATEST_ANSWERS
      end
    end
  end

  context "with multiple filter conditions" do
    context "with filter for missing values and ..." do
      it "... year" do
        missing2000 = missing_answers(2000)
        missing2000 << "Slate Rock and Gravel Company+2000"
        expect(search(status: :none, year: "2000").sort)
          .to eq(missing2000.sort)
      end

      it "... keyword" do
        expect(search(status: :none, company_name: "Inc").sort)
          .to eq(with_year(["Apple Inc.", "Google Inc."]))
      end

      it "... dataset" do
        expect(search(status: :none, dataset: "Evil Dataset").sort)
          .to eq(with_year(["Los Pollos Hermanos"]))
      end

      it "... company_category" do
        expect(search(status: :none, company_category: "A"))
          .to eq []
      end

      it "... company_category and year" do
        expect(search(status: :none, company_category: "A", year: "2001"))
          .to eq ["SPECTRE+2001"]
      end
    end

    context "when filtering for all values and ..." do
      it "... dataset" do
        expect(search(status: :all, dataset: "Evil Dataset"))
          .to contain_exactly("Death Star+2001", "SPECTRE+2000",
                              *with_year("Los Pollos Hermanos"))
      end

      it "... year" do
        i = all_companies.index("Death Star")
        all_companies[i] = "Death Star"
        expect(search(status: :all, year: "2001"))
          .to contain_exactly(*with_year(all_companies, 2001))
      end

      it "... company_category and year" do
        expect(search(status: :all, company_category: "A", year: "2001"))
          .to contain_exactly(*with_year(["SPECTRE", "Death Star"], 2001))
      end
    end

    it "dataset and company_category" do
      expect(search(dataset: "Evil Dataset", company_category: "A").sort)
        .to eq(["Death Star+2001", "SPECTRE+2000"])
    end
    it "year and company_category" do
      expect(search(year: "1977", company_category: "A"))
        .to eq(with_year("Death Star", 1977))
    end
    it "all in" do
      Timecop.freeze(Wikirate::HAPPY_BIRTHDAY) do
        expect(search(year: "1990",
                      company_category: "A",
                      dataset: "Evil Dataset",
                      updated: :today,
                      name: "star"))
          .to eq(with_year("Death Star", 1990))
      end
    end
  end

  context "with multi-category metric" do
    let(:metric_name) { "Joe_User+big_multi" }

    it "handles value arrays" do
      expect(search(value: ["1"])).to eq(["Sony Corporation+2010"])
    end
  end
end
