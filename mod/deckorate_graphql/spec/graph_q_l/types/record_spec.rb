RSpec.describe GraphQL::Types::Record do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["record"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        record(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:record_name) { "Jedi+disturbances in the Force+Death Star+1990" }

  describe "record: metric field" do
    it "returns record's metric" do
      query = query_string record_name, "metric { name } "
      expect(result(query)["metric"]["name"]).to eq("Jedi+disturbances in the Force")
    end
  end

  describe "record: company field" do
    it "returns String" do
      query = query_string record_name, "company { name }"
      expect(result(query)["company"]["name"]).to eq("Death Star")
    end
  end

  describe "record: year field" do
    it "returns the year" do
      query = query_string record_name, "year"
      expect(result(query)["year"]).to eq(1990)
    end
  end
end
