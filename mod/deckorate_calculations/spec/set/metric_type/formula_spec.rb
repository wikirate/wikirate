# -*- encoding : utf-8 -*-

require_relative "../../../spec/support/formula.rb"

RSpec.describe Card::Set::MetricType::Formula do
  include_context "formula"

  let(:metric_name) { "Joe User+RM" }
  let(:metric_name1) { "Joe User+researched number 1" }
  let(:metric_name2) { "Joe User+researched number 2" }
  let(:metric_name3) { "Joe User+researched number 3" }

  def build_formula formula
    format formula, metric_name1, metric_name2, metric_name3
  end

  describe "formula card" do
    let(:formula_card) { Card[:formula] }

    it "has codename" do
      expect(formula_card.codename).to eq :formula
    end

    it 'has type "metric type"' do
      expect(formula_card.type_id).to eq Card["metric type"].id
    end
  end

  describe "formula with year reference" do
    context "with single year" do
      subject(:answer_value) do
        take_answer_value "Apple Inc", 2015
      end

      def formula year:
        create_formula_metric year: year, add: { metric: metric_name1 }
      end
      # let(:formula) do
      #   "{{#{metric_name}|year:#{@year_expr} }}+{{#{metric_name1}}}"
      # end

      it "fixed year" do
        formula year: "2014"
        expect(answer_value).to eq "114"
      end
      it "relative year" do
        formula year: "-2"
        expect(answer_value).to eq "113"
      end
      it "current year" do
        formula year: "0"
        expect(answer_value).to eq "115"
      end

      it "latest" do
        formula year: "latest"
        expect(take_answer_value("Apple Inc", 2002)).to eq "115"
      end
    end

    it "all years" do
      # {{metric_name3|year: all}} + {{metric_name1}}
      create_formula_metric metric: metric_name3, method: "SUM",
                            year: "all", add: { metric: metric_name1 }
      expect(take_answer_value("Samsung", 2014)).to eq "12"
      expect(take_answer_value("Samsung", 2015)).to eq "7"
    end

    context "with total of" do
      subject(:answer_value) do
        take_answer_value "Apple Inc", 2015
      end

      def formula year:
        create_formula_metric method: "SUM",
                              year: year, add: { metric: metric_name1 }
      end

      # let(:formula) do
      #   "Total[{{ #{metric_name}|year:#{@year_expr} }}]+{{#{metric_name1}}}"
      # end

      it "relative range" do
        formula year: "-3..-1"
        expect(answer_value).to eq "139"
      end
      it "relative range with 0" do
        formula year: "-3..0"
        expect(answer_value).to eq "154"
      end
      it "relative range with ?" do
        formula year: "-3..?"
        expect(answer_value).to eq "154"
      end
      it "fixed range" do
        formula year: "2012..2013"
        expect(answer_value).to eq "125"
      end
      it "fixed start" do
        formula year: "2012..0"
        expect(answer_value).to eq "154"
      end
      it "list of years" do
        formula year: "2012, 2014"
        expect(answer_value).to eq "126"
      end
      it "all" do
        formula year: "all"
        # Total is unknown because two values are unknown
        expect(answer_value).to eq "Unknown"
      end
    end
  end

  describe "unknown option" do
    subject(:answer_value) do
      take_answer_value "Apple Inc", 2001
    end

    def formula unknown:
      create_formula_metric method: "numKnown", year: "2000..0", unknown: unknown
    end

    example "unknown option no_result" do
      formula unknown: "no_result"
      expect(answer_value).to eq nil
    end

    example "unknown option result_unknown" do
      formula unknown: "result_unknown"
      expect(answer_value).to eq "Unknown"
    end

    example "pass arbitrary value" do
      formula unknown: "1"
      expect(answer_value).to eq "2"
    end

    example "pass 'Unknown'" do
      formula unknown: "Unknown"
      expect(answer_value).to eq "1"
    end

    example "without unknown option" do
      formula unknown: nil
      expect(answer_value).to eq "Unknown"
    end
  end

  example "network aware formula" do
    create_formula_metric method: "SUM", related: "Jedi+more evil=yes",
                          metric: "Jedi+deadliness"
    expect(take_answer_value("Death Star", 1977)).to eq "90"
  end

  example "network aware formula using inverse relationship" do
    create_formula_metric method: "SUM", related: "Jedi+less evil=yes",
                          metric: "Jedi+deadliness"
    expect(take_answer_value("Los Pollos Hermanos", 1977)).to eq "150"
  end

  def calc_value company="Samsung", year="2014"
    calc_answer(company, year).value
  end

  def calc_answer company="Samsung", year="2014"
    Answer.where(metric_id: "Joe User+#{@metric_title}".card_id,
                 company_id: company.card_id, year: year.to_i).take
  end

  def test_calculation input, output
    expect(calc_value(*input)).to eq(output)
  end

  context "when created with formula" do
    before do
      @metric_title = "formula1"
      Card::Auth.as_bot do
        @metric = create_metric(
          name: @metric_title, type: :formula,
          formula: build_formula("{{%s}}*5+{{%s}}*2")
        )
      end
    end

    it "creates calculated values" do
      test_calculation [], "60"
      test_calculation %w[Samsung 2015], "29"
      test_calculation %w[Sony_Corporation], "9"
      not_researched_card = calc_answer "Death_Star", "1977"
      expect(not_researched_card).to be_falsey
    end

    context "when formula changes" do
      def update_formula new_formula
        Card::Auth.as_bot do
          @metric.formula_card.update! content: build_formula(new_formula)
        end
      end

      it "updates existing calculated value" do
        update_formula "{{%s}}*4+{{%s}}*2"
        expect(calc_value).to eq "50"
      end

      it "removes incomplete calculated value" do
        update_formula "{{%s}}*5+{{%s}}*2+{{%s}}"
        expect(calc_answer("Sony_Corporation", "2014")).to be_falsey
      end

      it "adds complete calculated value" do
        update_formula "{{%s}}*5"
        test_calculation %w[Death_Star 1977], "25"
      end
    end

    context "when input metric value is missing" do
      it "doesn't create calculated value" do
        expect(calc_answer("Death Star", "1977")).to be_falsey
      end
      it "creates calculated value if missing value is added" do
        Card::Auth.as_bot do
          Card["Joe User+researched number 2"].create_answer(
            company: "Death Star",
            year: "1977",
            value: "2",
            source: sample_source
          )
        end
        test_calculation %w[Death_Star 1977], "29"
      end
    end

    context "when input metric value changes" do
      it "updates calculated value" do
        card = Card["#{metric_name1}+Samsung+2014+value"]
        expect { card.update! content: "1" }
          .to change { calc_value }.from("60").to("15")
      end
      it "removes incomplete calculated values" do
        Card::Auth.as_bot { Card["#{metric_name1}+Samsung+2014"].delete! }
        expect(calc_answer).to be_falsey
      end
    end
  end

  context "when created without formula" do
    before do
      @metric_title = "formula2"
      @metric = create_metric name: @metric_title, type: :formula
    end

    it "creates calculated values if formula created" do
      Card::Auth.as_bot do
        Card.create! name: "#{@metric.name}+formula",
                     type_id: Card::PlainTextID,
                     content: build_formula("{{%s}}*5+{{%s}}*2")
      end
      test_calculation [], "60"
      test_calculation %w[Samsung 2015], "29"
      test_calculation %w[Sony_Corporation], "9"
      not_researched_card = calc_answer "Death_Star", "1977"
      expect(not_researched_card).to be_falsey
    end
  end
end
