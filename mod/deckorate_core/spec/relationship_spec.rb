RSpec.describe Relationship do
  def relation id=relation_id
    described_class.for_card id
  end
  let(:metric) { "Jedi+more evil" }
  let(:relation_name) { "#{metric}+Death Star+1977+Los Pollos Hermanos" }
  let(:relation_id) { relation_name.card_id }

  describe "create" do
    it "creates relationship entry" do
      create_answers "Jedi+more evil", true do
        Monster_Inc "2000" => { "Los_Pollos_Hermanos" => "no" }
      end

      r_id = "Jedi+more evil+Monster_Inc+2000+Los_Pollos_Hermanos".card_id
      relation = described_class.find_by_relationship_id r_id
      expect(relation).to be_instance_of(described_class)
      aggregate_failures "relationship id attributes" do
        { record_id: "Jedi+more evil+Monster Inc",
          subject_company_id: "Monster Inc",
          object_company_id: "Los Pollos Hermanos",
          answer_id: "Jedi+more evil+Monster Inc+2000",
          relationship_id: "Jedi+more evil+Monster Inc+2000+Los Pollos Hermanos",
          metric_id: "Jedi+more evil" }.each_pair do |attr, name|
          expect(relation.send(attr)).to eq(name.card_id),
                                         "#{attr}: #{relation.send(attr)}; "\
                                                 "expected: '#{name.card_id}'"
        end
        expect(relation.year).to eq 2000
        expect(relation.value).to eq "no"
        expect(relation.route).to eq Answer.route_index(:direct)
        expect(relation.latest).to eq true
        expect(relation.subject_company_id.cardname).to eq("Monster Inc")
        expect(relation.object_company_id.cardname).to eq("Los Pollos Hermanos")
      end
    end
  end

  describe "seeded relationships table" do
    it "one for each relationship" do
      expect(described_class.count)
        .to eq Card.search(type_id: Card::RelationshipID, return: :count)
    end

    describe "random example" do
      it "exists" do
        is_expected.to be_instance_of(described_class)
      end
      it "has subject_company_id" do
        expect(relation.subject_company_id).to eq "Death Star".card_id
      end
      it "has object_company_id" do
        expect(relation.object_company_id).to eq "Los Pollos Hermanos".card_id
      end
      it "has year" do
        expect(relation.year).to eq 1977
      end
      it "has metric_id" do
        expect(relation.metric_id).to eq metric.card_id
      end
      it "has value" do
        expect(relation.value).to eq "yes"
      end
    end
  end

  describe "delete" do
    it "removes entry" do
      relation_id
      delete relation_name
      expect(relation).to be_nil
    end

    xit "updates latest" do
      record = "Commons+Supplied by+SPECTRE"
      new_latest = described_class.find_by_answer_id "#{record}+1977".card_id
      new_latest.refresh # FIXME: shouldn't be needed; if needed, data was wrong
      expect(new_latest.latest).to be_falsey
      delete "#{record}+2000" # "+Los Pollos Hermanos"
      new_latest.refresh
      expect(new_latest.latest).to be_truthy
    end
  end

  describe "updates" do
    before do
      # fetch answer_id before the change
      relation_id
    end

    it "updates subject company" do
      update relation_name, name: "#{metric}+Google LLC+1977+Los Pollos Hermanos"
      expect(relation.subject_company_id).to eq "Google LLC".card_id
    end

    it "updates object company" do
      update relation_name, name: "#{metric}+Death Star+1977+Google LLC"
      expect(relation.object_company_id).to eq "Google LLC".card_id
    end

    context "when year changes" do
      example "doesn't change latest if still latest" do
        expect(relation.latest).to eq true
        name = "Commons+Supplied by+SPECTRE+2000"
        new_name = "Commons+Supplied by+SPECTRE+1999"
        update name, name: new_name
        relationship_id = "#{new_name}+Los_Pollos_Hermanos".card_id
        relation = described_class.find_by_relationship_id relationship_id
        expect(relation.latest).to eq true
      end
    end

    it "cannot update to metric for which value is invalid" do
      expect do
        update relation_name,
               name: "Commons+Supplied by+Google LLC+1977+Los Pollos Hermanos"
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "updates year" do
      update relation_name, name: "#{metric}+Death Star+1999+Los Pollos Hermanos"
      expect(relation.year).to eq 1999
    end

    it "updates value" do
      expect { update "#{relation_name}+value", content: "no" }
        .to change { relation.value }.from("yes").to("no")
    end
  end
end
