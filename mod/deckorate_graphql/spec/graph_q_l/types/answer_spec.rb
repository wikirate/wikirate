RSpec.describe GraphQL::Types::Answer do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["answer"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        answer(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:answer_name) { "Jedi+disturbances in the Force+Death Star+1990" }

  describe "answer: metric field" do
    it "returns answer's metric" do
      query = query_string answer_name, "metric { name } "
      expect(result(query)["metric"]["name"]).to eq("Jedi+disturbances in the Force")
    end
  end

  describe "answer: company field" do
    it "returns String" do
      query = query_string answer_name, "company { name }"
      expect(result(query)["company"]["name"]).to eq("Death Star")
    end
  end

  describe "answer: year field" do
    it "returns the year" do
      query = query_string answer_name, "year"
      expect(result(query)["year"]).to eq(1990)
    end
  end

end
