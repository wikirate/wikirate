# -*- encoding : utf-8 -*-

# the metric in the test database:
# Card::Metric.create name: 'Jedi+deadliness+Joe User',
#                     type: :score,
#                     formula: '{{Jedi+deadliness}}/10'
RSpec.describe Card::Set::MetricType::Score do
  let(:metric) { Card[@name] }

  before { @name = "Jedi+deadliness+Joe User" }

  def score_value company="Samsung", year="2014"
    score_answer(company, year).value
  end

  def score_answer company="Samsung", year="2014"
    Answer.where(metric_id: Card.fetch_id("Joe User+#{@metric_title}+Big Brother"),
                 company_id: Card.fetch_id(company), year: year.to_i)
          .take
  end

  describe "score for numerical metric" do
    context "when created with formula" do
      let(:metric_card) { Card[@metric_name] }

      before do
        @metric_title = "researched number 2"
        @metric_name = "Joe User+#{@metric_title}"
        Card::Auth.as_bot do
          @metric = create_metric(
            name: "#{@metric_name}+Big Brother", type: :score,
            formula: "{{#{@metric_name}}}*2"
          )
        end
      end
      it "creates score values" do
        expect(score_value).to eq("10.0")
        expect(score_value("Samsung", "2015")).to eq("4.0")
        expect(score_value("Sony_Corporation")).to eq("4.0")
        expect(score_answer("Death_Star", "1977")).to be_falsey
      end

      context "when formula changes" do
        def update_formula formula
          Card::Auth.as_bot do
            @metric.formula_card.update! content: formula
          end
        end
        it "updates existing rating value" do
          update_formula "{{#{@metric_name}}}*3"
          expect(score_value).to eq "10"
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
            metric_card.create_value company: "Death Star",
                                     year: "1977",
                                     value: "2",
                                     source: sample_source
          end
          expect(score_value("Death Star", "1977")).to eq("4.0")
        end
      end

      context "when input metric value changes" do
        it "updates score value" do
          Card["#{@metric_name}+Samsung+2014+value"].update! content: "1"
          expect(score_value).to eq "2.0"
        end
        it "removes score value that lost input metric value" do
          Card::Auth.as_bot do
            Card["#{@metric_name}+Samsung+2014+value"].delete
          end
          expect(score_answer).to be_falsey
        end
      end
    end

    context "when created without formula" do
      before do
        Card::Auth.as_bot do
          @metric_title = "researched number 1"
          @metric = create_metric name: "Joe User+#{@metric_title}+Big Brother",
                                  type: :score
        end
      end

      it "has basic metric as formula" do
        expect(Card["#{@metric.name}+formula"].content)
          .to eq "{{Joe User+#{@metric_title}}}"
      end

      it "creates score values if formula updated" do
        Card::Auth.as_bot do
          @metric.formula_card.update!(
            type_id: Card::PlainTextID,
            content: "{{Joe User+#{@metric_title}}}*2"
          )
        end
        expect(score_value).to eq("10")
        expect(score_value("Samsung", "2015")).to eq("10.0")
        expect(score_value("Sony_Corporation")).to eq("2.0")
      end
    end
  end

  context "when original value changed" do
    def answer metric
      Answer.where(metric_id: Card.fetch_id(metric),
                   company_id: Card.fetch_id("Death Star"), year: 1977).take
    end

    before do
      Card["Jedi+deadliness+Death Star+1977+value"].update! content: 40
    end

    it "updates scored valued" do
      expect(answer("Jedi+deadliness+Joe User").value).to eq "4.0"
    end

    it "updates dependent ratings" do
      expect(answer("Jedi+darkness rating").value).to eq "6.4"
    end
  end

  describe "score for multi-categorical formula", as_bot: true do
    it "sums values", as_bot: true do
      @metric_title = "small multi"
      @metric_name = "Joe User+small multi"
      @metric = create_metric(
        name: "#{@metric_name}+Big Brother",
        type: :score,
        formula: '{"1":"2", "2":4, "3":6}'
      )
      expect(score_value("Sony Corporation", "2010")).to eq "6.0"
    end

    it "updates when formula updated", as_bot: true do
      @metric_title = "small multi"
      @metric_name = "Joe User+small multi"
      @metric = create_metric(
        name: "#{@metric_name}+Big Brother",
        type: :score,
        formula: '{"1":2, "2":4, "3":6}'
      )
      expect(score_value("Sony Corporation", "2010")).to eq "6.0"
      @metric.formula_card.update_attributes!(
        type_id: Card::PlainTextID,
        content: '{"1":2, "2":5, "3":6}'
      )

      expect(score_value("Sony Corporation", "2010")).to eq "7.0"
    end
  end

  example "score with else case", as_bot: true do
    @metric_title = "small single"
    @metric_name = "Joe User+small single"
    @metric = create_metric(name: "#{@metric_name}+Big Brother", type: :score,
                            formula: '{"2":4, "3":6, "else": 5}')
    expect(score_value("Sony Corporation", "2010")).to eq "5.0"
  end

  example "score unknown value", as_bot: true do
    @metric_title = "RM"
    @metric_name = "Joe User+RM"
    @metric = create_metric(name: "#{@metric_name}+Big Brother", type: :score,
                            formula: '{"Unknown":0, "else": 10}')
    aggregate_failures do
      expect(score_value("Apple Inc", "2001")).to eq "0.0"
      expect(score_value("Apple Inc", "2010")).to eq "10.0"
    end
  end
end
