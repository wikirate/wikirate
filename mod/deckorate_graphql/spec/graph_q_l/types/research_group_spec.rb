RSpec.describe GraphQL::Types::ResearchGroup do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["researchGroup"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        researchGroup(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:research_group_name) { "Jedi" }

  describe "research_group: metrics field" do
    it "returns metrics linked with the research group" do
      query = query_string research_group_name, "metrics { id }"
      expect(result(query)["metrics"].count).to be_positive
    end
  end
end
