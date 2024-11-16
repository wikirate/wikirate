RSpec.describe GraphQL::Types::Dataset do
  def result query_string
    GraphQL::CardSchema.execute(query_string)["data"]["dataset"]
  end

  def query_string name, field
    <<-GRAPHQL
      query {
        dataset(name: "#{name}") {
          #{field}
        }
      }
    GRAPHQL
  end

  let(:dataset_name) { "Evil Dataset" }

  describe "dataset: metrics field" do
    it "returns the metrics included in dataset" do
      query = query_string dataset_name, "metrics { id } "
      expect(result(query)["metrics"].count).to be_positive
    end
  end

  describe "dataset: companies field" do
    it "returns the companies included in dataset" do
      query = query_string dataset_name, "companies { id } "
      expect(result(query)["companies"].count).to be_positive
    end
  end

  describe "dataset: records field" do
    it "returns the records included in dataset" do
      query = query_string dataset_name, "records { id } "
      expect(result(query)["records"].count).to be_positive
    end
  end
end
