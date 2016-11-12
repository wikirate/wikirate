# -*- encoding : utf-8 -*-

describe Card::Set::Right::FilterSearchTopic do
  let(:card) do
    card = Card.new name: "test card"
    card.singleton_class.send :include, Card::Set::Right::FilterSearchTopic
    card
  end
  describe "filter_wql" do
    subject { card.filter_wql }
    context "name argument" do
      before do
        allow(card).to receive(:filter_keys_with_values) do
          { name: "Animal Rights" }
        end
      end
      it { is_expected.to eq(name: "Animal Rights") }
    end

    context "company argument" do
      before do
        allow(card).to receive(:filter_keys_with_values) do
          { wikirate_company: "Animal Rights" }
        end
      end
      it { is_expected.to eq(referred_to_by: "Animal Rights") }
    end


    context "company argument" do
      before do
        allow(card).to receive(:filter_keys_with_values) do
          { wikirate_company: "Animal Rights" }
        end
      end
      it { is_expected.to eq(referred_to_by: "Animal Rights") }
    end
  end
  it "works" do
    #stub()
    expect(subject.target_type_id).to eq Card::WikirateTopicID
  end
end
