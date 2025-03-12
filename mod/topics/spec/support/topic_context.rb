RSpec.shared_context "when creating topics" do
  def create_topic! name, category, framework
    Card::Auth.as "joe admin" do
      Card.create! name: name,
                   type: :topic,
                   fields: {
                     category: category,
                     topic_framework: framework
                   }
    end
  end
end
