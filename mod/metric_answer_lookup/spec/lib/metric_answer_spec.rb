describe MetricAnswer do
  let(:metric) { "Joe User+researched" }
  let(:metric_answer) { "#{metric}+Apple_Inc+2013" }
  let(:metric_answer_id) { Card.fetch_id metric_answer }
  subject { MetricAnswer.find_by_metric_answer_id metric_answer_id }

  describe "seeded metric answer table" do
    it "has correct count" do
      expect(described_class.count).to eq Card.search(type_id: Card::MetricValueID, return: :count)
    end

    context "random example" do
      it "exists" do
        is_expected.to be_instance_of(MetricAnswer)
      end
      it "has company_id" do
        expect(subject.company_id).to eq Card.fetch_id("Apple Inc")
      end
      it "has year" do
        expect(subject.year).to eq 2013
      end
      it "has metric_id" do
        expect(subject.metric_id).to eq Card.fetch_id("Joe User+researched")
      end
      it "has metric_type_id" do
        expect(subject.metric_type_id).to eq Card.fetch_id("researched")
      end
      it "has designer_id" do
        expect(subject.designer_id).to eq Card.fetch_id("Joe User")
      end
      it "has value" do
        expect(subject.value).to eq "13"
      end
      it "has metric_name" do
        expect(subject.metric_name).to eq "Joe User+researched"
      end
      it "has company_name" do
        expect(subject.company_name).to eq "Apple_Inc"
      end
    end
  end

  # describe "#fetch_by" do
  #   it "handles company id" do
  #     expect(described_class.find_by)
  #   end
  # end

  describe "delete" do
    it "removes entry" do
      metric_answer_id
      delete metric_answer
      expect(subject).to be_nil
    end
  end

  describe "updates" do
    before do
      # fetch metric_answer_id before the change
      metric_answer_id
    end
    it "updates company" do
      update metric_answer, name: "Joe User+researched+Samsung+2013"
      expect(subject.company_id).to eq Card.fetch_id("Samsung")
      expect(subject.company_name).to eq "Samsung"
    end

    it "updates metric" do
      update metric_answer, name: "Joe User+researched number 2+Apple_Inc+2013"
      expect(subject.metric_id).to eq Card.fetch_id("Joe User+researched number 2")
      expect(subject.metric_name).to eq "Joe User+researched number 2"
    end

    it "updates year" do
      update metric_answer, name: "Joe User+researched+Apple_Inc+1999"
      expect(subject.year).to eq 1999
    end

    it "updates value" do
      update "#{metric_answer}+value", content: "85"
      expect(subject.value).to eq "85"
    end

    it "updates designer" do
      update "Joe User", name: "Jimmy User"
    end

    it "updates metric type" do
      update [metric, :metric_type], content: "[[Score]]"
      expect(subject.metric_type_id).to eq Card.fetch_id("score")
    end

    it "updates policy" do
      create_or_update [metric, :research_policy], content: "[[Community Assessed]]"
      expect(subject.policy_id).to eq Card.fetch_id("Community Assessed")
    end

    it "updates updated_at" do

    end
  end

  describe "fetch" do
    MetricAnswer.fetch company_id: Card.fetch_id("Apple Inc")
  end
end
