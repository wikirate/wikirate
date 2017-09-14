RSpec.describe Card::Query::CachedCountSorting do
  subject do
    Card::Query.run @query.reverse_merge return: :name, sort: :name
  end

  def sort args
    Card::Query.new return: :name, sort: args
  end

  describe "sql" do
    subject { sort(right: "company", item: "cached_count", return: "count").sql }

    it "joins with cached counts table" do
      is_expected.to include(
        "JOIN counts counts_table ON c1.id = counts_table.left_id AND "\
        "counts_table.right_id = #{Card::WikirateCompanyID}"
      )
    end
    it "orders by cached counts" do
      is_expected.to include("ORDER BY CAST(counts_table.value AS signed) asc")
    end
  end
end
