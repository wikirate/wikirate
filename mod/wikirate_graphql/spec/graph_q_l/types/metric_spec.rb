RSpec.describe GraphQL::Types::Query do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["metric"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        metric(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:metric_name) { "Jedi+disturbances in the force" }

  describe "metric: answers field" do
    it "returns answers pertaining to the metric" do
      query = query_string metric_name, "answers { metric { id } }"
      expect(result(query)["answers"].first["metric"]["id"]).to eq(metric_name.card_id)
    end
  end

  describe "metric: title field" do
    it "returns String" do
      query = query_string metric_name, "title"
      expect(result(query)["title"]).to eq("disturbances in the Force")
    end
  end
end
