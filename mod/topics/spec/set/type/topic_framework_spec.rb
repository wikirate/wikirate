RSpec.describe Card::Set::Type::TopicFramework do
  # Test topic is Steward Assessed with Joe User as steward
  let(:topic) { "Test Topics+created topic".card }
  let(:metric) { "Joe User+researched number 3".card }

  def steward_can action, card
    Card::Auth.as "Joe User" do
      expect(card).to be_ok(action)
    end
  end

  def nonsteward_cant action, card
    Card::Auth.as "Joe Camel" do
      expect(card).not_to be_ok(action)
    end
  end

  %i[create update delete].each do |action|
    specify "steward can #{action} topic" do
      steward_can action, topic
    end

    specify "nonsteward cannot #{action} topic" do
      nonsteward_cant action, topic
    end

    specify "super user can #{action} topic", with_user: "Joe Admin"  do
      expect(topic).to be_ok(action)
    end
  end

  it "prevents nonstewards from adding topic taggings", with_user: "Joe Camel" do
    expect do
      metric.topic_card.update!(content: topic.name)
    end.to raise_error ActiveRecord::RecordInvalid,
                       /cannot change stewarded topic: .*created topic/
  end
end
