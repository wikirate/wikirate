# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Abstract::Record::Sources do
  def record_for metric_name
    Card.new type: :record, name: "#{metric_name}+Samsung+2012"
  end

  describe "#source_required?" do
    it "is true for a normal researched metric" do
      expect(record_for("Joe User+RM")).to be_source_required
    end

    it "is false for non-hybrid calculated metrics" do
      expect(record_for("Jedi+darkness rating")).not_to be_source_required
    end

    it "is true for hybrid metrics" do
      expect(record_for("Jedi+friendliness")).to be_source_required
    end
  end

  describe "required fields" do
    let(:existing_citation) do
      Card["Joe User+RM+Apple Inc+2000+source"]
    end

    it "requires that (most) records have sources and a value" do
      sourceless = record_for("Joe User+RM")
      sourceless.save
      expect(sourceless.errors.attribute_names).to eq(%i[value source])
    end

    it "prevents deletion of source citations", as_bot: true do
      expect { existing_citation.delete! }
        .to raise_error(ActiveRecord::RecordInvalid, /required field/)
    end
  end
end
