RSpec.describe Answer do
  def answer id=answer_id
    described_class.for_card id
  end

  let(:metric) { "Joe User+RM" }
  let(:answer_name) { "#{metric}+Apple_Inc+2013" }
  let(:answer_id) { answer_name.card_id }

  describe "seeded metric answer table" do
    it "has more than researched values" do
      expect(described_class.count)
        .to be > Card.search(type_id: Card::AnswerID, return: :count)
    end

    describe "random example" do
      it "exists" do
        is_expected.to be_instance_of(described_class)
      end
      it "has company_id" do
        expect(answer.company_id).to eq "Apple Inc.".card_id
      end
      it "has year" do
        expect(answer.year).to eq 2013
      end
      it "has metric_id" do
        expect(answer.metric_id).to eq "Joe User+RM".card_id
      end
      it "has metric_type_id" do
        expect(answer.metric.metric_type_id).to eq "researched".card_id
      end
      it "has designer_id" do
        expect(answer.metric.designer_id).to eq "Joe User".card_id
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

  describe "#relation?" do
    context "when metric is a relation metric" do
      let(:relationship) do
        answer "Jedi+more evil+Death Star+1977".card_id
      end

      it "returns true" do
        expect(relationship).to be_relation
      end
    end

    context "when metric is not a relation metric" do
      it "returns false" do
        expect(answer).not_to be_relation
      end
    end
  end

  describe "delete" do
    it "removes entry" do
      answer_id
      delete answer_name
      expect(answer).to be_nil
    end

    it "updates latest" do
      record = "#{metric}+Apple_Inc"
      new_latest = described_class.for_card "#{record}+2014".card_id
      expect(new_latest.latest).to be_falsey
      delete "#{record}+2015"
      new_latest.refresh
      expect(new_latest.latest).to be_truthy
    end

    it "allows re-creation" do
      delete answer_name
      create name: answer_name,
             "+value": "Unknown",
             "+source": :space_opera_source.cardname
      expect(answer.value).to eq("Unknown")
    end
  end

  describe "updates" do
    before do
      # fetch answer_id before the change
      answer_id
    end
    it "updates company" do
      update answer_name, name: "Joe User+RM+Samsung+2013"
      expect(answer.company_id).to eq "Samsung".card_id
      expect(answer.company_name).to eq "Samsung"
    end

    it "updates metric" do
      update answer_name, name: "Joe User+researched number 2+Apple_Inc+2013"
      expect(answer.metric_id).to eq "Joe User+researched number 2".card_id
      expect(answer.metric_name).to eq "Joe User+researched number 2"
    end

    it "updates metric when metric names changes" do
      update metric, name: "Joe User+invented"
      expect(answer.metric_name).to eq "Joe User+invented"
    end

    context "when year changes" do
      # record has answer for 2002 and 2015
      let(:record_name) { "Joe User+researched number 1+Apple Inc" }

      it "updates year" do
        update answer_name, name: "Joe User+RM+Apple_Inc+1999"
        expect(answer.year).to eq 1999
      end

      def new_latest old_year, new_year
        old_name = [record_name, old_year.to_s].cardname
        new_name = [record_name, new_year.to_s].cardname
        update old_name, name: new_name
        described_class.for_card(new_name.card_id).latest
      end

      def latest_for_year year
        described_class.for_card([record_name, year.to_s].card_id).latest
      end

      it "doesn't change latest if still latest" do
        expect(new_latest(2015, 2014)).to be_truthy
      end

      it "updates latest when card is no longer latest" do
        expect(new_latest(2015, 2000)).to be_falsey
        expect(latest_for_year(2002)).to be_truthy
      end

      it "updates latest when card is newly latest" do
        expect(new_latest(2002, 2020)).to be_truthy
        expect(latest_for_year(2015)).to be_falsey
      end
    end

    it "updates value" do
      expect { update "#{answer_name}+value", content: "85" }
        .to change { answer.value }.from("13").to("85")
    end

    it "updates designer" do
      update "Joe User", name: "Jimmy User"
      expect(answer.metric.designer_id.cardname).to eq("Jimmy User")
    end

    it "updates metric type" do
      update [metric, :metric_type], content: "[[Score]]"
      expect(answer.metric.metric_type_id).to eq "score".card_id
    end

    it "updates policy" do
      Card.create! name: [metric, :assessment], content: "[[Community Assessed]]"
      expect(answer.metric.policy_id).to eq "Community Assessed".card_id
    end

    xit "updates updated_at" do
    end
  end
end
