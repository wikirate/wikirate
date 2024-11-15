RSpec.describe Card::RecordQuery::ValueFilters do
  include_context "record query"

  let(:default_filters) { { company_id: "Samsung".card_id, year: :latest } }
  let(:answer_parts) { [1, -1] } # metric and year

  let :unknown_answers do
    with_year(
      ["deadliness", "deadliness", "deadliness",
       "double friendliness", "friendliness", "Victims by Employees"], 1977
    )
  end

  describe "#status_query" do
    it "finds unknown values" do
      expect(search(status: :unknown))
        .to eq unknown_answers
    end

    it "finds known values" do
      all_known = search(status: :known).all? do |a|
        a.s.include?("researched number") || a.s.include?("descendant")
      end
      expect(all_known).to be_truthy
    end
  end

  describe "#value_query" do
    let(:default_filters) { { metric_id: metric_name.card_id, year: :latest } }
    let(:answer_parts) { [-2, -1] }
    let(:default_sort) { {} }

    context "with multi-category metric" do
      let(:metric_name) { "Joe_User+big_multi" }

      specify do
        expect(search(value: ["1"])).to eq(["Sony Corporation+2010"])
      end
    end
  end
end
