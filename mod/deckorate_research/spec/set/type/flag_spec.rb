# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Flag do
  include Cardio::FlagSpecHelper

  let(:record) { sample_record }

  describe "lookup for flagged record" do
    # note, much of the relevant lookup code is in card-mod-flag, which is appropriate,
    # because that code is reusuable in different lookup contexts.  But we're not
    # really set up to test lookups there yet.

    context "when adding a flag" do
      it "updates the count and verification level" do
        expect(record.lookup.verification).to eq(1)
        expect(record.lookup.open_flags).to eq(0)

        flag_subject record.name

        expect(record.lookup.verification).to eq(0)
        expect(record.lookup.open_flags).to eq(1)
      end
    end

    context "when deleting a flag" do
      # this record is flagged in default data
      let(:record) { ["Fred", "dinosaurlabor", "Death Star", "2010"].card }

      it "updates the count and verification level" do
        expect(record.lookup.verification).to eq(0)
        expect(record.lookup.open_flags).to eq(1)

        record.open_flag_cards.first.delete!

        expect(record.lookup.verification).to eq(3)
        expect(record.lookup.open_flags).to eq(0)
      end
    end
  end
end
