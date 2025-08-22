RSpec.shared_context "when creating topics" do
  def create_topic! name, category, framework
    Card::Auth.as "joe admin" do
      Card.create! name: [framework, name].compact.cardname,
                   type: :topic,
                   fields: {
                     category: [framework, category].compact.cardname,
                   }
    end
  end
end
