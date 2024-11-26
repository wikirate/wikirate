# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Flag do
  include Cardio::FlagSpecHelper

  let(:answer) { sample_answer }

  describe "lookup for flagged answer" do
    # note, much of the relevant lookup code is in card-mod-flag, which is appropriate,
    # because that code is reusuable in different lookup contexts.  But we're not
    # really set up to test lookups there yet.

    context "when adding a flag" do
      it "updates the count and verification level" do
        expect(answer.lookup.verification).to eq(1)
        expect(answer.lookup.open_flags).to eq(0)

        flag_subject answer.name

        expect(answer.lookup.verification).to eq(0)
        expect(answer.lookup.open_flags).to eq(1)
      end
    end

    context "when deleting a flag" do
      # this answer is flagged in default data
      let(:answer) { ["Fred", "dinosaurlabor", "Death Star", "2010"].card }

      it "updates the count and verification level" do
        expect(answer.lookup.verification).to eq(0)
        expect(answer.lookup.open_flags).to eq(1)

        answer.open_flag_cards.first.delete!

        expect(answer.lookup.verification).to eq(3)
        expect(answer.lookup.open_flags).to eq(0)
      end
    end
  end
end
