# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::MetricType::Score do
  let(:scored_name) { "Joe User+researched number 2" }
  let(:scored) { Card[scored_name] }

  let(:score_name) { "#{scored_name}+Big Brother" }
  let(:score_formula) { "answer * 2" }
  let(:formula_type) { :formula }

  # TODO: stop creating this score over and over. move to test data
  let :score do
    Card::Auth.as_bot do
      create_metric name: score_name, type: :score, formula_type => score_formula
    end
  end

  def score_value company="Samsung", year="2014"
    score_answer(company, year)&.value
  end

  def score_answer company="Samsung", year="2014"
    ::Answer.where(
      metric_id: score.id,
      company_id: company.card_id,
      year: year
    ).take
  end

  def card_subject
    score
  end

  check_views_for_errors views: views(:html).push(:metric_properties) - [:select]

  describe "score for numerical metric" do
    context "when created with formula" do
      it "creates score values" do
        expect(score_value).to eq("10")
        expect(score_value("Samsung", "2015")).to eq("4")
        expect(score_value("Sony_Corporation")).to eq("4")
        expect(score_answer("Death_Star", "1977")).to be_falsey
      end

      context "when formula changes" do
        def update_formula formula
          Card::Auth.as_bot do
            score.formula_card.update! content: formula
          end
        end

        it "updates existing score" do
          update_formula "answer * 3"
          expect(score_value).to eq "15"
        end

        # it 'fails if basic metric is not used in formula' do
        #   #update_formula '{{Jedi+deadliness}}'
        #   pending 'not checked yet'
        # end
      end

      context "when a input metric value is missing" do
        it "doesn't create score value" do
          expect(score_answer("Death Star", "1977")).to be_falsey
        end
        it "creates score value if missing value is added" do
          Card::Auth.as_bot do
            scored.create_answer company: "Death Star",
                                 year: "1977",
                                 value: "2",
                                 source: sample_source
          end
          expect(score_value("Death Star", "1977")).to eq("4")
        end
      end

      context "when input metric value changes" do
        let(:answer_name) { "#{scored_name}+Samsung+2014" }

        it "updates score value" do
          Card["#{answer_name}+value"].update! content: "1"
          expect(score_value).to eq "2"
        end

        it "removes score value that lost input metric value" do
          Card::Auth.as_bot { Card[answer_name].delete }
          expect(score_answer).to be_falsey
        end
      end
    end

    context "when created without formula" do
      let(:score) do
        Card::Auth.as_bot do
          create_metric name: score_name, type: :score
        end
      end

      it "creates score values if formula updated" do
        Card::Auth.as_bot do
          score.formula_card.update!(content: "answer * 2")
        end
        expect(score_value).to eq("10")
        expect(score_value("Samsung", "2015")).to eq("4")
        expect(score_value("Sony_Corporation")).to eq("4")
      end
    end
  end

  context "when original value changed" do
    def answer metric
      ::Answer.where(
        metric_id: metric.card_id,
        company_id: "Death Star".card_id,
        year: 1977
      ).take
    end

    before do
      Card["Jedi+deadliness+Death Star+1977+value"].update! content: 40
    end

    it "updates scored valued" do
      expect(answer("Jedi+deadliness+Joe User").value).to eq "4"
    end

    it "updates dependent ratings" do
      expect(answer("Jedi+darkness rating").value).to eq "6.4"
    end
  end

  describe "score for multi-categorical formula", as_bot: true do
    let(:scored_name) { "Joe User+small multi" }
    let(:formula_type) { :rubric }
    let(:score_formula) { '{"1": 2, "2":4, "3":6}' }

    it "sums values", as_bot: true do
      score
      expect(score_value("Sony Corporation", "2010")).to eq "6.0"
    end

    it "updates when formula updated", as_bot: true do
      score.rubric_card.update! content: '{"1":2, "2":5, "3":6}'
      expect(score_value("Sony Corporation", "2010")).to eq "7.0"
    end
  end

  context "with else case" do
    let(:scored_name) { "Joe User+small single" }
    let(:formula_type) { :rubric }

    let(:score_formula) { '{"2":4, "3":6, "else": 5}' }

    example do
      score
      expect(score_value("Sony Corporation", "2010")).to eq "5.0"
    end
  end

  context "with unknown case" do
    let(:scored_name) { "Jedi+disturbances in the Force" }
    let(:formula_type) { :rubric }
    let(:score_formula) { '{"Unknown":0, "else": 10}' }

    example do
      aggregate_failures do
        score
        expect(score_value("Slate Rock and Gravel Company", "2006")).to eq "0.0"
        expect(score_value("Slate Rock and Gravel Company", "2005")).to eq "10.0"
      end
    end
  end

  context "with year restrictions" do
    it "scores only applicable year (single)" do
      score.year_card.update! content: "2014"
      expect(score_value("Samsung", "2014")).to eq("10")
      expect(score_value("Samsung", "2015")).to be_nil # scored metric has data for 2015
    end

    it "scores only applicable years (multiple)" do
      score.year_card.update! content: %w[2013 2014]
      expect(score_value("Samsung", "2014")).to eq("10")
      expect(score_value("Samsung", "2015")).to be_nil
    end
  end

  context "with company group restrictions" do
    let(:scored_name) { "Joe User+researched number 1" }

    it "scores only applicable companies" do
      score.company_group_card.update! content: "Deadliest"
      expect(score_value("Samsung", "2014")).to be_nil # not in group
      expect(score_value("Death Star", "1977")).to eq("10")
    end
  end
end
