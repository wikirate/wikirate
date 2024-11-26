RSpec.describe GraphQL::Types::Source do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["source"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        source(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:source_name) { "Source-000000001" }

  describe "source: title field" do
    it "returns String" do
      query = query_string source_name, "title"
      expect(result(query)["title"]).to eq("Opera")
    end
  end

  describe "sources: years field" do
    it "returns years linked with the source" do
      query = query_string source_name, "years"
      expect(result(query)["years"]).to include(1977)
    end
  end

  describe "sources: answer field" do
    it "returns answers linked with the source" do
      query = query_string source_name, "answers { metric { id } }"
      expect(result(query)["answers"].count).to be_positive
    end
  end

  describe "sources: metrics field" do
    it "returns metrics linked with the source" do
      query = query_string source_name, "metrics { id }"
      expect(result(query)["metrics"].count).to be_positive
    end
  end
end
