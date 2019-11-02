# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::MetricAnswer::Validate do
  def answer_for metric_name
    Card.new type: :metric_answer, name: "#{metric_name}+Samsung+2012"
  end

  describe "#source_required?" do
    it "is true for a normal researched metric" do
      expect(answer_for("Joe User+RM").source_required?).to be_truthy
    end

    it "is false if metric is tagged with 'no source'" do
      Card.create! name: "Joe User+RM+tag", content: "no source"
      expect(answer_for("Joe User+RM").source_required?).to be_falsy
    end

    it "is false for non-hybrid calculated metrics" do
      expect(answer_for("Jedi+darkness rating").source_required?).to be_falsey
    end

    it "is true for hybrid metrics" do
      expect(answer_for("Jedi+friendliness").source_required?).to be_truthy
    end
  end

  describe "required fields" do
    let(:existing_citation) do
      Card["Joe User+RM+Apple Inc+2000+source"]
    end

    it "requires that (most) answers have sources and a value" do
      sourceless = answer_for("Joe User+RM")
      sourceless.save
      expect(sourceless.errors.keys).to eq(%i[value source])
    end

    it "prevents deletion of source citations", as_bot: true do
      expect { existing_citation.delete! }
        .to raise_error(ActiveRecord::RecordInvalid, /required field/)
    end
  end
end
