# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::MetricType::Formula do
  let(:metric_name) { "Joe User+RM" }
  let(:metric_name1) { "Joe User+researched number 1" }
  let(:metric_name2) { "Joe User+researched number 2" }
  let(:metric_name3) { "Joe User+researched number 3" }

  let(:formula_metric_name) { "Jedi+formula1" }

  let :variables do
    [
      { metric: metric_name, name: "m1" },
      { metric: metric_name1, name: "m2" }
    ]
  end

  def answer company: "Samsung", year: "2014", metric: "Jedi+formula1"
    Answer.where(
      metric_id: metric.card_id,
      company_id: company.card_id,
      year: year
    ).take
  end

  def answer_value **args
    answer(**args)&.value
  end

  def create_formula formula="m1 + m2", vars=variables
    create_metric name: formula_metric_name,
                  type: :formula,
                  variables: vars.to_json,
                  formula: formula
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
      let :value do
        answer_value company: "Apple Inc", year: 2015
      end

      def formula year:
        variables.first[:year] = year
        create_formula
      end
      # let(:formula) do
      #   "{{#{metric_name}|year:#{@year_expr} }}+{{#{metric_name1}}}"
      # end

      it "fixed year" do
        formula year: "2014"
        expect(value).to eq "114"
      end
      it "relative year" do
        formula year: "-2"
        expect(value).to eq "113"
      end
      it "current year" do
        formula year: "0"
        expect(value).to eq "115"
      end

      it "latest" do
        formula year: "latest"
        expect(answer_value(company: "Apple Inc", year: 2002)).to eq "115"
      end
    end

    it "all years" do
      variables.first.merge! metric: metric_name3, year: "all"
      create_formula "SUM m1, m2"
      expect(answer_value).to eq "12"
      expect(answer_value(year: 2015)).to eq "7"
    end

    context "with total of" do
      let :value do
        answer_value company: "Apple Inc", year: 2015
      end

      def formula year:
        variables.first[:year] = year
        create_formula "SUM m1, m2"
      end

      # let(:formula) do
      #   "Total[{{ #{metric_name}|year:#{@year_expr} }}]+{{#{metric_name1}}}"
      # end

      it "relative range" do
        formula year: "-3..-1"
        expect(value).to eq "139"
      end
      it "relative range with 0" do
        formula year: "-3..0"
        expect(value).to eq "154"
      end
      it "relative range with ?" do
        formula year: "-3..?"
        expect(value).to eq "154"
      end
      it "fixed range" do
        formula year: "2012..2013"
        expect(value).to eq "125"
      end
      it "fixed start" do
        formula year: "2012..0"
        expect(value).to eq "154"
      end
      it "list of years" do
        formula year: "2012, 2014"
        expect(value).to eq "126"
      end
      it "all" do
        formula year: "all"
        # Total is unknown because two values are unknown
        expect(value).to eq "Unknown"
      end
    end
  end

  describe "unknown option" do
    let :value do
      answer_value company: "Apple Inc", year: 2001
    end

    def formula(unknown:)
      var = variables.first.merge year: "2000..0", unknown: unknown
      create_formula "numKnown [m1].flat()", [var]
    end

    example "unknown option no_result" do
      formula unknown: "no_result"
      expect(value).to eq nil
    end

    example "unknown option result_unknown" do
      formula unknown: "result_unknown"
      expect(value).to eq "Unknown"
    end

    example "pass arbitrary value" do
      formula unknown: "1"
      expect(value).to eq "2"
    end

    example "pass 'Unknown'" do
      formula unknown: "Unknown"
      expect(value).to eq "1"
    end

    example "without unknown option" do
      formula unknown: nil
      expect(value).to eq "Unknown"
    end
  end

  context "with network aware formula" do
    def formula related
      vars = [{ metric: "Jedi+deadliness", name: "m1", company: related }]
      create_formula "SUM m1", vars
    end

    example "using direct relationship" do
      formula "Jedi+more evil"
      expect(answer_value(company: "Death Star", year: 1977)).to eq "90"
    end

    example "using inverse relationship" do
      formula "Jedi+less evil"
      expect(answer_value(company: "Los Pollos Hermanos", year: 1977)).to eq "150"
    end
  end

  def test_calculation input, output
    expect(_value(*input)).to eq(output)
  end

  context "when created with formula" do
    let :variables do
      [
        { metric: metric_name1, name: "m1" },
        { metric: metric_name2, name: "m2" }
      ]
    end

    before do
      create_formula "m1 * 5 + m2 * 2"
    end

    it "creates calculated values" do
      expect(answer_value).to eq("60")
      expect(answer_value(year: 2015)).to eq("29")
      expect(answer_value(company: "Sony_Corporation")).to eq("9")
      expect(answer(company: "Death_Star", year: 1977)).to be_falsey
    end

    context "when formula changes" do
      def update_formula fields
        Card::Auth.as_bot do
          formula_metric_name.card.update!(fields: fields)
        end
      end

      it "updates existing calculated value" do
        update_formula formula: "m1 * 4 + m2 * 2"
        expect(answer_value).to eq "50"
      end

      it "removes incomplete calculated value" do
        vars = variables << { metric: metric_name3, name: "m3" }
        update_formula formula: "m1*5+m2*2+m3", variables: vars.to_json
        expect(answer(company: "Sony_Corporation")).to be_falsey
      end

      it "adds complete calculated value" do
        update_formula formula: "m1*5", variables: [variables.first].to_json
        expect(answer_value(company: "Death Star", year: 1977)).to eq("25")
      end
    end

    context "when input metric value is missing" do
      it "doesn't create calculated value" do
        expect(answer(company: "Death Star", year: 1977)).to be_falsey
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
        expect(answer_value(company: "Death Star", year: 1977)).to eq("29")
      end
    end

    context "when input metric value changes" do
      it "updates calculated value" do
        card = Card["#{metric_name1}+Samsung+2014+value"]
        expect { card.update! content: "1" }
          .to change { answer_value }.from("60").to("15")
      end
      it "removes incomplete calculated values" do
        Card::Auth.as_bot { Card["#{metric_name1}+Samsung+2014"].delete! }
        expect(answer).to be_falsey
      end
    end
  end

  context "when created without formula" do
    let :variables do
      [
        { metric: metric_name1, name: "m1" },
        { metric: metric_name2, name: "m2" }
      ]
    end

    before do
      create_formula nil
    end

    it "creates calculated values if formula created", as_bot: true do
      Card.create! name: [formula_metric_name, :formula], content: "m1 * 5 + m2 * 2"
      expect(answer_value).to eq("60")
      expect(answer_value(year: 2015)).to eq("29")
      expect(answer_value(company: "Sony_Corporation")).to eq("9")
      expect(answer(company: "Death_Star", year: 1977)).to be_falsey
    end
  end
end
