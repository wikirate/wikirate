RSpec.describe Card::Set::Right::WikirateTopic do
  let :metric_topic do
    Card["Jedi+disturbances in the force+topic"]
  end

  describe "create/update" do
    it "autotags supertopic if it exists", as_bot: true do
      # "Energy" is subtopic of "Taming"
      Card.create! name: "Taming+subtopic",
                   content: "[[Energy]]",
                   type_id: Card::PointerID

      # metric updated with topic "Energy"
      metric_topic.add_item "Energy"
      metric_topic.save!

      # ... so metric should now be tagged with "Taming"
      expect(metric_topic.item_names).to include("Taming")
    end
  end
end
