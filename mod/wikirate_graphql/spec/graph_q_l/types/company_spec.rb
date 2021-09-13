RSpec.describe GraphQL::Types::Query do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["company"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        company(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  describe "company: answers field" do
    it "returns answers pertaining to the company" do
      query = query_string "Death Star", "answers { company { name } }"
      expect(result(query)["answers"].first["company"]["name"]).to eq("Death Star")
    end
  end

  # describe "company: logo_url field" do
  #   it "returns String" do
  #     query = query_string "Death Star", "logoUrl"
  #     expect(result(query)["logoUrl"]).to be_a String
  #   end
  # end
end
