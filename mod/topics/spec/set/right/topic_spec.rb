RSpec.describe Card::Set::Right::Topic do
  let :metric_topic do
    "Joe User+RM".card.topic_card
  end

  describe "create/update" do
    it "autotags supertopic if it exists", as_bot: true do
      # metric updated with topic "Energy"
      metric_topic.add_item! "Wikirate ESG Topics+Energy"

      # ... so metric should now be tagged with %i[esg_topics environment].cardname
      expect(metric_topic.item_names).to include(%i[esg_topics environment].cardname)
    end
  end
end
