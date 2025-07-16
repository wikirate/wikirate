RSpec.describe Card::Set::Right::Topic do
  let :metric_topic do
    "Joe User+RM".card.topic_card
  end

  describe "create/update" do
    it "autotags supertopic if it exists", as_bot: true do
      # metric updated with topic "Energy"
      metric_topic.add_item! "Energy"

      # ... so metric should now be tagged with "Force"
      expect(metric_topic.item_names).to include("Force")
    end
  end
end
