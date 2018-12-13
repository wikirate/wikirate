 RSpec.describe Answer do
  def answer id=answer_id
    described_class.find_by_answer_id id
  end
  let(:metric) { "Joe User+RM" }
  let(:answer_name) { "#{metric}+Apple_Inc+2013" }
  let(:answer_id) { Card.fetch_id answer_name }

  describe "seeded metric answer table" do
    it "has more than researched values" do
      expect(described_class.count)
        .to be > Card.search(type_id: Card::MetricAnswerID, return: :count)
    end

    describe "random example" do
      it "exists" do
        is_expected.to be_instance_of(described_class)
      end
      it "has company_id" do
        expect(answer.company_id).to eq Card.fetch_id("Apple Inc.")
      end
      it "has year" do
        expect(answer.year).to eq 2013
      end
      it "has metric_id" do
        expect(answer.metric_id).to eq Card.fetch_id("Joe User+RM")
      end
      it "has metric_type_id" do
        expect(answer.metric_type_id).to eq Card.fetch_id("researched")
      end
      it "has designer_id" do
        expect(answer.designer_id).to eq Card.fetch_id("Joe User")
      end
      it "has value" do
        expect(answer.value).to eq "13"
      end
      it "has metric_name" do
        expect(answer.metric_name).to eq "Joe User+RM"
      end
      it "has company_name" do
        expect(answer.company_name).to eq "Apple Inc."
      end
    end
  end

  describe "#relationship?" do
    context "when metric is a relationship metric" do
      let(:relationship_answer) do
        answer Card.fetch_id("Jedi+more evil+Death Star+1977")
      end
      it "returns true" do
        expect(relationship_answer.relationship?).to be_truthy
      end
    end

    context "when metric is not a relationship metric" do
      it "returns false" do
        expect(answer.relationship?).to be_falsey
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
      answer_id
      delete answer_name
      expect(answer).to be_nil
    end

    it "updates latest" do
      record = "#{metric}+Apple_Inc"
      new_latest = described_class.find_by_answer_id Card.fetch_id("#{record}+2014")
      expect(new_latest.latest).to be_falsey
      delete "#{record}+2015"
      new_latest.refresh
      expect(new_latest.latest).to be_truthy
    end
  end

  describe "updates" do
    before do
      # fetch answer_id before the change
      answer_id
    end
    it "updates company" do
      update answer_name, name: "Joe User+RM+Samsung+2013"
      expect(answer.company_id).to eq Card.fetch_id("Samsung")
      expect(answer.company_name).to eq "Samsung"
    end

    it "updates metric" do
      update answer_name, name: "Joe User+researched number 2+Apple_Inc+2013"
      expect(answer.metric_id).to eq Card.fetch_id("Joe User+researched number 2")
      expect(answer.metric_name).to eq "Joe User+researched number 2"
    end

    it "updates metric when metric names changes" do
      update metric, name: "Joe User+invented"
      expect(answer.metric_name).to eq "Joe User+invented"
    end

    it "updates year" do
      update answer_name, name: "Joe User+RM+Apple_Inc+1999"
      expect(answer.year).to eq 1999
    end

    it "updates value" do
      expect { update "#{answer_name}+value", content: "85" }
        .to change { answer.value }.from("13").to("85")
    end

    it "updates designer" do
      update "Joe User", name: "Jimmy User"
    end

    it "updates metric type" do
      update [metric, :metric_type], content: "[[Score]]"
      expect(answer.metric_type_id).to eq Card.fetch_id("score")
    end

    it "updates policy" do
      create_or_update [metric, :research_policy], content: "[[Community Assessed]]"
      expect(answer.policy_id).to eq Card.fetch_id("Community Assessed")
    end

    it "updates updated_at" do
    end
  end

  # describe "fetch" do
  #   described_class.fetch company_id: Card.fetch_id("Apple Inc")
  # end

  describe "calculated answers" do
    let(:metric) { Card["Jedi+friendliness"] }

    specify "#calculated_answer", with_user: "Joe User" do
      a = described_class.create_calculated_answer metric, "Death Star", 2001, "50"
      expect(a.attributes.symbolize_keys)
        .to include(
          metric_name: "Jedi+friendliness", company_name: "Death Star", year: 2001,
          record_name: "Jedi+friendliness+Death Star", metric_type_id: Card::FormulaID,
          value: "50", numeric_value: 50,
          creator_id: Card.fetch_id("Joe User"), editor_id: nil,
          updated_at: be_within(2).of(Time.now),
          record_id: be_a_integer, designer_id: be_a_integer, metric_id: be_a_integer,
          answer_id: nil, checkers: nil, check_requester: nil, policy_id: nil,
          latest: true, imported: false
        )
    end

    specify "#update_value", with_user: "Joe User" do
      a = described_class.create_calculated_answer metric, "Death Star", 2001, "50"
      a.update_value "100.5"
      expect(a.attributes.symbolize_keys)
        .to include answer_id: nil,
                    value: "100.5",
                    numeric_value: 100.5,
                    creator_id: Card.fetch_id("Joe User"),
                    updated_at: be_within(1).of(Time.now),
                    latest: true,
                    editor_id: Card.fetch_id("Joe User")
    end
  end
end
