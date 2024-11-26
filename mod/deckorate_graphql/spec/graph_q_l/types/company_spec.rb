RSpec.describe GraphQL::Types::Company do
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

  describe "company: answer field" do
    it "returns answer pertaining to the company" do
      query = query_string "Death Star", "answer { company { name } }"
      expect(result(query)["answer"].first["company"]["name"]).to eq("Death Star")
    end
  end

  describe "company: headquarters field" do
    it "returns headquarters of company" do
      query = query_string "Google LLC", "headquarters"
      expect(result(query)["headquarters"]).to eq("California (United States)")
    end
  end

  describe "company: wikipedia field" do
    it "returns wikipedia page pertaining to the company" do
      query = query_string "Death Star", "wikipedia"
      expect(result(query)["wikipedia"]).to eq("Death Star")
    end
  end

  describe "company: relationships field" do
    it "returns relationships pertaining to the company" do
      field = "relationships { objectCompany { name }, subjectCompany { name } }"
      query = query_string "Death Star", field
      results = result(query)
      expect([
               results["relationships"].first["objectCompany"]["name"],
               results["relationships"].first["subjectCompany"]["name"]
             ]).to include("Death Star")
    end
  end

  describe "company: answer field filtered by year" do
    it "returns answer only related to year 2010 pertaining to the company" do
      query = query_string "Death Star", "answer (year: \"2010\"){ year }"
      expect(result(query)["answer"].first["year"]).to eq(2010)
    end
  end
end
