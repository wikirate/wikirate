RSpec.describe Card::Set::TypePlusRight::Topic::Category do
  describe "creation" do
    let(:topic) { Card[%i[esg_topics social].cardname] }
    let(:category_pointer) { topic.category_card }

    it "is restricted to moderators" do
      expect(category_pointer).not_to be_ok(:create)
    end

    it "does not allow non-topics as items", as_bot: true do
      expect do
        category_pointer.add_item! "Death Star"
      end.to raise_error(/invalid type: Company/)
    end

    it "triggers updates to subtopic referers", as_bot: true do
      pointer = category_pointer
      pointer.add_item %i[esg_topics environment].cardname
      pointer.save!
      # the dinosaur labor metric is tagged with Wikirate ESG Topics+Social,
      # so making Wikirate ESG Topics+Social a subtopic of Force should tag dinosaur labor with Force
      expect(%i[esg_topics environment].cardname.card.metric_card.item_names).to include("Fred+dinosaurlabor")
    end
  end
end
