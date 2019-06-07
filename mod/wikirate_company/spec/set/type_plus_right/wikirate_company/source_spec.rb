RSpec.describe Card::Set::TypePlusRight::WikirateCompany::Source do
  describe "#wql_hash" do
    # note: this is primarily testing that the potential right_plus conflict
    # is handled correctly.
    def card_subject
      Card.fetch "Death Star+source", new: {}
    end

    subject { card_subject.wql_hash }

    let :right_plus_val do
      [Card::WikirateCompanyID, { refer_to: Card.fetch_id("Death Star") }]
    end

    it "finds sources with +company cards that refer to Death Star by default" do
      is_expected.to include(type_id: Card::SourceID, right_plus: [right_plus_val])
    end

    context "with additional right_plus filters" do
      before do
        Card::Env.params[:filter] = { wikirate_topic: "Force" }
      end

      it "adds filters to right_plus_array" do
        is_expected.to include(
          right_plus: [[Card::WikirateTopicID, { refer_to: "Force" }],
                       right_plus_val])
      end
    end
  end
end
