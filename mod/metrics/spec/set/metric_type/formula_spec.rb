# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::MetricType::Formula do
  before do
    @metric_name = "Joe User+researched"
    @metric_name1 = "Joe User+researched number 1"
    @metric_name2 = "Joe User+researched number 2"
    @metric_name3 = "Joe User+researched number 3"
  end

  def build_formula formula
    format formula, @metric_name1, @metric_name2, @metric_name3
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
    subject do
      formula_metric = create_metric name: "rating1", type: :formula, formula: formula
      Answer.where(metric_name: formula_metric.name, company_id: company_id, year: 2015)
            .take.value
    end

    let(:company_id) { Card.fetch_id "Apple Inc" }


    context "single year" do
      let(:formula) do
        "{{#{@metric_name}|year:#{@year_expr} }}+{{#{@metric_name1}}}"
      end

      it "fixed year" do
        @year_expr = "2014"
        is_expected.to eq "114.0"
      end
      it "relative year" do
        @year_expr = "-2"
        is_expected.to eq "113.0"
      end
      it "current year" do
        @year_expr = "0"
        is_expected.to eq "115.0"
      end
    end

    context "sum of" do
      let(:formula) do
        "Sum[{{ #{@metric_name}|year:#{@year_expr} }}]+{{#{@metric_name1}}}"
      end

      it "relative range" do
        @year_expr = "-3..-1"
        is_expected.to eq "139.0"
      end
      it "relative range with 0" do
        @year_expr = "-3..0"
        is_expected.to eq "154.0"
      end
      it "relative range with ?" do
        @year_expr = "-3..?"
        is_expected.to eq "154.0"
      end
      it "fixed range" do
        @year_expr = "2012..2013"
        is_expected.to eq "125.0"
      end
      it "fixed start" do
        @year_expr = "2012..0"
        is_expected.to eq "154.0"
      end
      it "list of years" do
        @year_expr = "2012, 2014"
        is_expected.to eq "126.0"
      end
    end
  end

  describe "basic properties" do
    before do
      @name = "Jedi+friendliness"
    end
    let(:metric) { Card[@name] }

    describe "#metric_type" do
      subject { metric.metric_type }

      it { is_expected.to eq "Formula" }
    end
    describe "#metric_type_codename" do
      subject { metric.metric_type_codename }

      it { is_expected.to eq :formula }
    end
    describe "#metric_designer" do
      subject { metric.metric_designer }

      it { is_expected.to eq "Jedi" }
    end
    describe "#metric_designer_card" do
      subject { metric.metric_designer_card }

      it { is_expected.to eq Card["Jedi"] }
    end
    describe "#metric_title" do
      subject { metric.metric_title }

      it { is_expected.to eq "friendliness" }
    end
    describe "#metric_title_card" do
      subject { metric.metric_title_card }

      it { is_expected.to eq Card["friendliness"] }
    end
    describe "#question_card" do
      subject { metric.question_card.name }

      it { is_expected.to eq "Jedi+friendliness+Question" }
    end
    describe "#value_type" do
      subject { metric.value_type }

      it { is_expected.to eq "Free Text" }
    end
    describe "#categorical?" do
      subject { metric.categorical? }

      it { is_expected.to be_falsey }
    end
    describe "#researched?" do
      subject { metric.researched? }

      it { is_expected.to be_falsey }
    end
    describe "#scored?" do
      subject { metric.scored? }

      it { is_expected.to be_falsey }
    end
  end

  def calc_value company="Samsung", year="2014"
    calc_answer(company, year).value
  end

  def calc_answer company="Samsung", year="2014"
    Answer.where(metric_id: Card.fetch_id("Joe User+#{@metric_title}"),
                 company_id: Card.fetch_id(company), year: year.to_i).take
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
      test_calculation [], "60.0"
      test_calculation %w[Samsung 2015], "29.0"
      test_calculation %w[Sony_Corporation], "9.0"
      not_researched_card = calc_answer "Death_Star", "1977"
      expect(not_researched_card).to be_falsey
    end

    context "and formula changes" do
      def update_formula new_formula
        Card::Auth.as_bot do
          @metric.formula_card.update_attributes!(
            content: build_formula(new_formula)
          )
        end
      end

      it "updates existing calculated value" do
        update_formula "{{%s}}*4+{{%s}}*2"
        expect(calc_value).to eq "50.0"
      end

      it "removes incomplete calculated value" do
        update_formula "{{%s}}*5+{{%s}}*2+{{%s}}"
        expect(calc_answer("Sony_Corporation", "2014")).to be_falsey
      end

      it "adds complete calculated value" do
        update_formula "{{%s}}*5"
        test_calculation %w[Death_Star 1977], "25.0"
      end
    end

    context "and input metric value is missing" do
      it "doesn't create calculated value" do
        expect(calc_answer("Death Star", "1977")).to be_falsey
      end
      it "creates calculated value if missing value is added" do
        Card::Auth.as_bot do
          Card["Joe User+researched number 2"].create_value(
            company: "Death Star",
            year: "1977",
            value: "2",
            source: sample_source
          )
        end
        test_calculation %w[Death_Star 1977], "29.0"
      end
    end

    context "and input metric value changes" do
      it "updates calculated value" do
        card = Card["#{@metric_name1}+Samsung+2014+value"]
        expect { card.update_attributes! content: "1" }
          .to change { calc_value }.from("60.0").to("15.0")
      end
      it "removes incomplete calculated values" do
        Card::Auth.as_bot do
          Card["#{@metric_name1}+Samsung+2014+value"].delete
        end
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
      test_calculation [], "60.0"
      test_calculation %w[Samsung 2015], "29.0"
      test_calculation %w[Sony_Corporation], "9.0"
      not_researched_card = calc_answer "Death_Star", "1977"
      expect(not_researched_card).to be_falsey
    end
  end

  xit "handles wolfram formula" do
    # TODO: get Wolfram API is working again!!
    Card::Auth.as_bot do
      Card::Metric.create(
        name: "Jedi+Force formula",
        type: :formula,
        formula: "{{Jedi+deadliness}}/10 - 5 + " \
               'Boole[{{Jedi+disturbances in the Force}} == "yes"]'
      )
    end
    expect(Card["Jedi+Force formula+Death Star+1977+value"].content).to eq "6"
  end
end
