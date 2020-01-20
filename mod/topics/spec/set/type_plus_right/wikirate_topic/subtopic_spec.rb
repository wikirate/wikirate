RSpec.describe Card::Set::TypePlusRight::WikirateTopic::Subtopic do
  describe "creation" do
    let(:topic) { Card["Force"] }
    let(:subtopic_pointer) { topic.subtopic_card }

    it "is restricted to moderators" do
      expect(subtopic_pointer.ok?(:create)).to be_falsey
    end

    it "does not allow non-topics as items", as_bot: true do
      pointer = subtopic_pointer
      pointer.add_item "Death Star"
      pointer.save
      expect(pointer.errors[:content]).to include("invalid subtopic: Death Star")
    end

    it "triggers updates to subtopic referers", as_bot: true do
      pointer = subtopic_pointer
      pointer.add_item "Taming"
      pointer.save!
      # the dinosaur labor metric is tagged with Taming,
      # so making Taming a subtopic of Force should tag dinosaur labor with Force
      expect(topic.metric_card.item_names).to include("Fred+dinosaurlabor")
    end
  end
end
