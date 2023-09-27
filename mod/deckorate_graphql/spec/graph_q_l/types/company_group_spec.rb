RSpec.describe GraphQL::Types::CompanyGroup do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["companyGroup"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        companyGroup(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:company_group_name) { "Googliest" }

  describe "company_group: companies field" do
    it "returns companies linked with the company group" do
      query = query_string company_group_name, "companies { name }"
      expect(result(query)["companies"].first["name"]).to eq("Google LLC")
    end
  end
end
