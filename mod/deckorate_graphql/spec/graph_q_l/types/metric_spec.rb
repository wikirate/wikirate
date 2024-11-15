RSpec.describe GraphQL::Types::Metric do
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

  describe "metric: records field" do
    it "returns records pertaining to the metric" do
      query = query_string metric_name, "records { metric { id } }"
      expect(result(query)["records"].first["metric"]["id"]).to eq(metric_name.card_id)
    end
  end

  describe "metric: title field" do
    it "returns String" do
      query = query_string metric_name, "title"
      expect(result(query)["title"]).to eq("disturbances in the Force")
    end
  end

  describe "metric: valueType field" do
    it "returns value type" do
      query = query_string metric_name, "valueType"
      expect(result(query)["valueType"]).to eq("Category")
    end
  end

  describe "metric: valueOptions field" do
    it "returns value options" do
      query = query_string metric_name, "valueOptions"
      expect(result(query)["valueOptions"]).to eq(%w[yes no])
    end
  end
end
