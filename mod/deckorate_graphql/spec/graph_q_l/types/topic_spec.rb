RSpec.describe GraphQL::Types::Topic do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["topic"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        topic(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:topic_name) { %i[esg_topics environment].cardname }

  describe "topic: datasets field" do
    it "returns datasets linked with the topic" do
      query = query_string topic_name, "datasets { id }"
      expect(result(query)["datasets"].count).to be_positive
    end
  end

  describe "topic: metrics field" do
    it "returns metrics linked with the topic" do
      query = query_string topic_name, "metrics { id }"
      expect(result(query)["metrics"].count).to be_positive
    end
  end
end
