RSpec.describe Card::AnswerQuery::Sorting do
  include_context "answer query"

  # @return [Array] of answer cards
  def sort_by sort_by, sort_dir: :asc, researched_only: false
    query = { year: :latest }
    query[:metric_type] = "Researched" if researched_only
    altered_results { run_query(query, sort_by => sort_dir) }
  end

  context "with company filtering" do
    let(:answer_parts) { [1, -1] }
    let(:default_filters) { { company_id: "Death Star".card_id, year: :latest } }
    let(:sorted_designer) { ["Commons", "Fred", "Jedi", "Joe User"] }

    let :latest_answers_by_bookmarks do
      [
        "disturbances in the Force+2001", "Victims by Employees+1977",
        "Sith Lord in Charge+1977", "dinosaurlabor+2010",
        "cost of planets destroyed+1977", "friendliness+1977", "deadliness+1977",
        "deadliness+1977", "disturbances in the Force+2001", "darkness rating+1977",
        "descendant 1+1977", "descendant 2+1977", "descendant hybrid+1977",
        "double friendliness+1977", "researched number 1+1977", "know the unknowns+1977",
        "more evil+1977", "RM+1977", "deadliness+1977", "Company Category+2019",
        "disturbance delta+2001"
      ]
    end

    context "when sorting by designer name" do
      let(:answer_parts) { [0] }

      it "(asc)" do
        expect(sort_by(:metric_designer, sort_dir: :asc).uniq).to eq(sorted_designer)
      end

      it "sorts by designer name (desc)" do
        expect(sort_by(:metric_designer, sort_dir: :desc).uniq)
          .to eq(sorted_designer.reverse)
      end
    end

    context "when sorting by metric title" do
      let(:answer_parts) { [1] }

      specify do
        sorted = sort_by(:metric_title)
        indices =
          ["cost of planets destroyed", "darkness rating", "deadliness",
           "researched number 1", "Victims by Employees"].map do |t|
            sorted.index(t)
          end
        expect(indices).to eq [1, 2, 3, 17, 20]
      end
    end

    it "sorts by recently updated" do
      expect(sort_by(:updated_at, sort_dir: :desc, researched_only: true).first)
        .to eq "dinosaurlabor+2010"
    end

    it "sorts by bookmarkers" do
      actual = sort_by :metric_bookmarkers, sort_dir: :desc
      expected = latest_answers_by_bookmarks

      bookmarked = (0..1)
      not_bookmarked = (2..-1)

      expect(actual[bookmarked]).to contain_exactly(*expected[bookmarked])
      expect(actual[not_bookmarked]).to contain_exactly(*expected[not_bookmarked])
    end
  end

  context "with metric filtering" do
    let :latest_answers do
      ["Death Star+2001", "Monster Inc+2000",
       "Slate Rock and Gravel Company+2006", "SPECTRE+2000"]
    end

    let(:metric_name) { "Jedi+disturbances in the Force" }
    let(:metric_id) { metric_name.card_id }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }
    let(:default_filters) { { metric_id: metric_id, year: :latest } }

    it "sorts by company name (asc)" do
      expect(sort_by(:company_name)).to eq(latest_answers)
    end

    it "sorts by company name (desc)" do
      expect(sort_by(:company_name, sort_dir: "desc")).to eq(latest_answers.reverse)
    end

    it "sorts categories by value" do
      res = sort_by(:value)
      yes_index = res.index "Death Star+2001"
      no_index = res.index "Slate Rock and Gravel Company+2006"
      expect(no_index).to be < yes_index
    end

    context "with relationship counts" do
      let(:metric_name) { "Jedi+deadliness" }

      it "sorts numerically" do
        expect(sort_by(:value))
          .to eq(["Samsung+1977",
                  "Slate Rock and Gravel Company+2005",
                  "Los Pollos Hermanos+1977",
                  "SPECTRE+1977",
                  "Death Star+1977"])
      end
    end

    context "with relationship counts" do
      let(:metric_name) { "Jedi+Victims by Employees" }

      it "sorts numerically" do
        expect(sort_by(:value))
          .to eq(with_year(["Samsung",
                            "Slate Rock and Gravel Company",
                            "Monster Inc",
                            "Los Pollos Hermanos",
                            "Death Star",
                            "SPECTRE"], 1977))
      end
    end
  end
end
