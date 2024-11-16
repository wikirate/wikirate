RSpec.describe Record do
  def record id=record_id
    described_class.for_card id
  end

  let(:metric) { "Joe User+RM" }
  let(:record_name) { "#{metric}+Apple_Inc+2013" }
  let(:record_id) { record_name.card_id }

  describe "seeded metric record table" do
    it "has more than researched values" do
      expect(described_class.count)
        .to be > Card.search(type_id: Card::RecordID, return: :count)
    end

    describe "random example" do
      it "exists" do
        is_expected.to be_instance_of(described_class)
      end
      it "has company_id" do
        expect(record.company_id).to eq "Apple Inc.".card_id
      end
      it "has year" do
        expect(record.year).to eq 2013
      end
      it "has metric_id" do
        expect(record.metric_id).to eq "Joe User+RM".card_id
      end
      it "has metric_type_id" do
        expect(record.metric.metric_type_id).to eq "researched".card_id
      end
      it "has designer_id" do
        expect(record.metric.designer_id).to eq "Joe User".card_id
      end
      it "has value" do
        expect(record.value).to eq "13"
      end
      it "has metric_name" do
        expect(record.metric_name).to eq "Joe User+RM"
      end
      it "has company_name" do
        expect(record.company_name).to eq "Apple Inc."
      end
    end
  end

  describe "#relation?" do
    context "when metric is a relation metric" do
      let(:relationship) do
        record "Jedi+more evil+Death Star+1977".card_id
      end

      it "returns true" do
        expect(relationship).to be_relation
      end
    end

    context "when metric is not a relation metric" do
      it "returns false" do
        expect(record).not_to be_relation
      end
    end
  end

  describe "delete" do
    it "removes entry" do
      record_id
      delete record_name
      expect(record).to be_nil
    end

    it "updates latest" do
      record_log = "#{metric}+Apple_Inc"
      new_latest = described_class.for_card "#{record_log}+2014".card_id
      expect(new_latest.latest).to be_falsey
      delete "#{record_log}+2015"
      new_latest.refresh
      expect(new_latest.latest).to be_truthy
    end

    it "allows re-creation" do
      delete record_name
      create name: record_name,
             "+value": "Unknown",
             "+source": :space_opera_source.cardname
      expect(record.value).to eq("Unknown")
    end
  end

  describe "updates" do
    before do
      # fetch record_id before the change
      record_id
    end
    it "updates company" do
      update record_name, name: "Joe User+RM+Samsung+2013"
      expect(record.company_id).to eq "Samsung".card_id
      expect(record.company_name).to eq "Samsung"
    end

    it "updates metric" do
      update record_name, name: "Joe User+researched number 2+Apple_Inc+2013"
      expect(record.metric_id).to eq "Joe User+researched number 2".card_id
      expect(record.metric_name).to eq "Joe User+researched number 2"
    end

    it "updates metric when metric names changes" do
      update metric, name: "Joe User+invented"
      expect(record.metric_name).to eq "Joe User+invented"
    end

    context "when year changes" do
      # record_log has records for 2002 and 2015
      let(:record_log_name) { "Joe User+researched number 1+Apple Inc" }

      it "updates year" do
        update record_name, name: "Joe User+RM+Apple_Inc+1999"
        expect(record.year).to eq 1999
      end

      def new_latest old_year, new_year
        old_name = [record_log_name, old_year.to_s].cardname
        new_name = [record_log_name, new_year.to_s].cardname
        update old_name, name: new_name
        described_class.for_card(new_name.card_id).latest
      end

      def latest_for_year year
        described_class.for_card([record_log_name, year.to_s].card_id).latest
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
      expect { update "#{record_name}+value", content: "85" }
        .to change { record.value }.from("13").to("85")
    end

    it "updates designer" do
      update "Joe User", name: "Jimmy User"
      expect(record.metric.designer_id.cardname).to eq("Jimmy User")
    end

    it "updates metric type" do
      update [metric, :metric_type], content: "[[Score]]"
      expect(record.metric.metric_type_id).to eq "score".card_id
    end

    it "updates policy" do
      Card.create! name: [metric, :research_policy], content: "[[Community Assessed]]"
      expect(record.metric.policy_id).to eq "Community Assessed".card_id
    end

    xit "updates updated_at" do
    end
  end
end
