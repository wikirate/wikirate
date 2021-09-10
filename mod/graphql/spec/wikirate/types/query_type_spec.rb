RSpec.describe Wikirate::Types::QueryType do
  def result query_string
    Wikirate::Schema.execute(query_string)["data"]
  end

  describe "card field" do
    it "finds a card by id and returns name name" do
      query_string = <<-GRAPHQL
        query {
          card(id: #{:wikirate_topic.card_id}) {
            name
          }
        }
      GRAPHQL
      expect(result(query_string).dig("card","name")).to eq("Topic")
    end
  end
end
