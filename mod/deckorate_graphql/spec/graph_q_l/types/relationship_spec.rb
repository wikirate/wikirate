RSpec.describe GraphQL::Types::Relationship do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["relationship"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        relationship(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:relationship_name) { "Commons+Supplied by+SPECTRE+2000+Google LLC" }

  describe "relationship: metric field" do
    it "returns relationship's metric" do
      query = query_string relationship_name, "metric { name } "
      expect(result(query)["metric"]["name"]).to eq("Commons+Supplied by")
    end
  end

  describe "relationship: subject company field" do
    it "returns String" do
      query = query_string relationship_name, "subjectCompany { name }"
      expect(result(query)["subjectCompany"]["name"]).to eq("SPECTRE")
    end
  end

  describe "relationship: object company field" do
    it "returns String" do
      query = query_string relationship_name, "objectCompany { name }"
      expect(result(query)["objectCompany"]["name"]).to eq("Google LLC")
    end
  end

  describe "relationship: year field" do
    it "returns the year" do
      query = query_string relationship_name, "year"
      expect(result(query)["year"]).to eq(2000)
    end
  end
end
