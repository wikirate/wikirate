RSpec.describe Card::Set::TypePlusRight::Company::Source do
  include FilterSpecHelper

  it_behaves_like "cached count", ["Death Star", :source], 4, 1 do
    let :add_one do
      card = Card.fetch sample_source(:apple), :company, new: {}
      card.add_item! "Death Star"
    end

    let :delete_one do
      Card[sample_source(:star_wars), :company].drop_item! "Death Star"
    end
  end

  describe "#cql_hash" do
    # note: this is primarily testing that the potential right_plus conflict
    # is handled correctly.
    def card_subject
      Card.fetch "Death Star+source", new: {}
    end

    subject { card_subject.cql_hash }

    let :right_plus_val do
      [Card::CompanyID, { refer_to: "Death Star".card_id }]
    end

    it "finds sources with +company cards that refer to Death Star by default" do
      is_expected.to include(type_id: Card::SourceID, right_plus: right_plus_val)
    end

    context "with additional right_plus filters" do
      subject { card_subject.format(:base).search_params }

      before do
        add_filter :year, "1977"
      end

      it "adds filters to right_plus_array" do
        is_expected.to include(
          right_plus: [[:year.card_id, { refer_to: "1977" }], right_plus_val]
        )
      end
    end
  end
end
