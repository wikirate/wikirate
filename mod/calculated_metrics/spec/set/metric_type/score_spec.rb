# -*- encoding : utf-8 -*-

# the metric in the test database:
# Card::Metric.create name: 'Jedi+deadliness+Joe User',
#                     type: :score,
#                     formula: '{{Jedi+deadliness}}/10'
RSpec.describe Card::Set::MetricType::Score do
  let(:metric) { Card[@name] }

  before { @name = "Jedi+deadliness+Joe User" }

  describe "score card" do
    let(:score_card) { Card[:score] }

    it { is_expected.to be_truthy }
    it "has codename" do
      expect(score_card.codename).to eq :score
    end
    it 'has type "metric type"' do
      expect(score_card.type_id).to eq Card["metric type"].id
    end
  end

  describe "#metric_type" do
    subject { metric.metric_type }

    it { is_expected.to eq "Score" }
  end

  describe "#metric_type_codename" do
    subject { metric.metric_type_codename }

    it { is_expected.to eq :score }
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

    it { is_expected.to eq "deadliness" }
  end

  describe "#metric_title_card" do
    subject { metric.metric_title_card }

    it { is_expected.to eq Card["deadliness"] }
  end

  describe "#question_card" do
    subject { metric.question_card.name }

    it { is_expected.to eq "Jedi+deadliness+Joe User+Question" }
  end

  describe "#value_type" do
    subject { metric.value_type }

    it { is_expected.to eq "Number" }
  end

  describe "#categorical?" do
    subject { metric.categorical? }

    it { is_expected.to be_falsey }
  end

  describe "#researched?" do
    subject { metric.researched? }

    it { is_expected.to be_falsey }
  end

  describe "#score?" do
    subject { metric.score? }

    it { is_expected.to be_truthy }
  end

  describe "#scorer" do
    subject { metric.scorer }

    it { is_expected.to eq "Joe User" }
  end

  describe "#scorer_card" do
    subject { metric.scorer_card }

    it { is_expected.to eq Card["Joe User"] }
  end

  describe "#basic_metric" do
    subject { metric.basic_metric }

    it { is_expected.to eq "Jedi+deadliness" }
  end

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

  describe "score for multi-categorical formula" do
    it "sums values" do
      @metric_title = "small multi"
      @metric_name = "Joe User+#{@metric_title}"
      Card::Auth.as_bot do
        @metric = create_metric(
          name: "#{@metric_name}+Big Brother",
          type: :score,
          formula: '{"1":2, "2":4, "3":6}'
        )
      end

      expect(score_value("Sony Corporation", "2010")).to eq "6.0"
    end
  end
end
