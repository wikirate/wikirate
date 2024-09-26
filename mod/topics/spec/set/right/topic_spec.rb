RSpec.describe Card::Set::Right::Topic do
  let :metric_topic do
    Card["Jedi+disturbances in the force+topic"]
  end

  describe "create/update" do
    it "autotags supertopic if it exists", as_bot: true do
      # "Energy" is in the Environment Category"
      Card.create! name: "Energy+category", content: "Environment"

      # metric updated with topic "Energy"
      metric_topic.add_item! "Energy"

      # ... so metric should now be tagged with "Taming"
      expect(metric_topic.item_names).to include("Environment")
    end
  end
end
